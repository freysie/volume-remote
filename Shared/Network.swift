import SwiftUI
import Network
import MultipeerConnectivity
#if os(macOS)
@testable import ISSoundAdditions
#endif

struct RemoteDevice: Identifiable {
  let id = UUID()
  let peer: MCPeerID?
  var name: String
  var isConnected = false
  var volume = 0.0
  var isMuted = false
  var brightness: Float = -1
  
  init(_ name: String) {
    peer = nil
    self.name = name
  }
  
  init(_ peer: MCPeerID) {
    self.peer = peer
    name = peer.displayName
  }
}

enum PeerCommand: Codable {
  case state(volume: Float, isMuted: Bool)
  case toggleMute
  case decreaseVolume
  case increaseVolume
  case setVolume(Double)

  case brightness(Float)
  case setBrightness(Float)
  case decreaseBrightness
  case increaseBrightness
}

class Network: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate, MCAdvertiserAssistantDelegate, ObservableObject {
  static let service = "fa-volremote"
  
  static var currentDeviceName: String {
#if os(iOS)
    UIDevice.current.name
#elseif os(macOS)
    Host.current().localizedName ?? ""
#else
    ""
#endif
  }
  
  @Published private(set) var isReachable = false
  @Published private(set) var devices = [MCPeerID: RemoteDevice]()
  
  private let monitor = NWPathMonitor()
  private let monitorQueue = DispatchQueue(label: "local.VolumeRemote.network-path-monitor")
  private let peer = MCPeerID(displayName: Network.currentDeviceName)
  private var session: MCSession!
#if os(iOS)
  private var serviceBrowser: MCNearbyServiceBrowser!
#elseif os(macOS)
  private var serviceAdvertiser: MCNearbyServiceAdvertiser!
  private var advertiserAssistant: MCAdvertiserAssistant!
#endif
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()
  
  override init() {
    super.init()
    
    monitor.pathUpdateHandler = { path in
      DispatchQueue.main.async {
        self.isReachable = path.status == .satisfied
      }
    }
    
    monitor.start(queue: monitorQueue)
    
    session = MCSession(peer: peer)
    session.delegate = self
    
#if os(iOS)
    serviceBrowser = MCNearbyServiceBrowser(peer: peer, serviceType: Self.service)
    serviceBrowser.delegate = self
    serviceBrowser.startBrowsingForPeers()
#elseif os(macOS)
    serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: Self.service)
    serviceAdvertiser.delegate = self
    serviceAdvertiser.startAdvertisingPeer()

    // advertiserAssistant = MCAdvertiserAssistant(serviceType: Self.service, discoveryInfo: nil, session: session)
    // advertiserAssistant.delegate = self
    // advertiserAssistant.start()
    
    try! Sound.output.addVolumeObserver { newValue in
      self.send(.state(volume: newValue, isMuted: Sound.output.isMuted), to: Array(self.devices.values))
    }
    
    try! Sound.output.addMuteObserver { newValue in
      self.send(.state(volume: Sound.output.volume, isMuted: newValue), to: Array(self.devices.values))
    }

    let observer = Unmanaged.passUnretained(self).toOpaque()
    DisplayServicesRegisterForBrightnessChangeNotifications(CGMainDisplayID(), observer) { _, observer, _, _, userInfo in
      guard let brightness = (userInfo as NSDictionary?)?["value"] as? Float else { return }
      let `self` = Unmanaged<Network>.fromOpaque(observer!).takeUnretainedValue()

      self.send(.brightness(brightness), to: Array(self.devices.values))
      print(brightness)
    }
#endif
  }
  
  func connect(_ device: RemoteDevice) {
    guard let peer = device.peer else { return }
#if os(iOS)
    serviceBrowser.invitePeer(peer, to: session, withContext: nil, timeout: -1)
#endif
  }
  
  func send(_ command: PeerCommand, to devices: [RemoteDevice]) {
    print((#function, command, devices))
    do {
      let data = try encoder.encode(command)
      try session.send(data, toPeers: devices.compactMap { $0.peer }, with: .reliable)
    } catch {
      print(error)
    }
  }
  
  // MARK: Delegate Methods
  
  func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
    print((#function, error))
  }
  
  @MainActor func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
    devices[peerID] = RemoteDevice(peerID)
  }
  
  @MainActor func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
    devices.removeValue(forKey: peerID)
  }
  
  func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
    invitationHandler(true, session)
  }

  func advertiserAssistantWillPresentInvitation(_ advertiserAssistant: MCAdvertiserAssistant) {
    print(#function)
  }
  
  func advertiserAssistantDidDismissInvitation(_ advertiserAssistant: MCAdvertiserAssistant) {
    print(#function)
  }
  
  func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
    print((#function, peerID, state, state.rawValue))
    
    DispatchQueue.main.async { [self] in
#if os(macOS)
      if state == .connected {
        devices[peerID] = RemoteDevice(peerID)
        send(.state(volume: Sound.output.volume, isMuted: Sound.output.isMuted), to: [devices[peerID]!])
      }
#elseif os(iOS)
      guard var device = devices[peerID] else { fatalError() }
      device.isConnected = state == .connected
      devices[peerID] = device
#endif
    }
  }
  
  @MainActor func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
    print((#function, data, from: peerID))
    guard var device = devices[peerID] else { fatalError() }
    
    do {
      let command = try decoder.decode(PeerCommand.self, from: data)
      switch command {
#if os(iOS)
      case .state(let volume, let isMuted):
        device.volume = Double(volume)
        device.isMuted = isMuted
        devices[peerID] = device

      case .brightness(let value):
        device.brightness = value
        devices[peerID] = device

#elseif os(macOS)
      case .setVolume(let value):
        Sound.output.volume = Float(value)

      case .toggleMute:
        Sound.output.isMuted.toggle()

      case .increaseVolume:
        Sound.output.increaseVolume(by: 1/16)

      case .decreaseVolume:
        Sound.output.decreaseVolume(by: 1/16)

      case .setBrightness(let value):
        DisplayServicesSetBrightness(CGMainDisplayID(), value)

      case .increaseBrightness:
        var brightness: Float = 0
        DisplayServicesGetBrightness(CGMainDisplayID(), &brightness)
        DisplayServicesSetBrightness(CGMainDisplayID(), brightness + 1/16)

      case .decreaseBrightness:
        var brightness: Float = 0
        DisplayServicesGetBrightness(CGMainDisplayID(), &brightness)
        DisplayServicesSetBrightness(CGMainDisplayID(), brightness - 1/16)

#endif

      default:
        print("unhandled command \(command)")
      }
    } catch {
      print(error)
    }
  }
  
  func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
  
  func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
  
  func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}
