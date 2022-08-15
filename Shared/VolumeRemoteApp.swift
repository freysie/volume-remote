import SwiftUI

class AppSettings: ObservableObject {
  @AppStorage("controls") var controls: Controls = .slider
  @AppStorage("fadesBezel") var fadesBezel: Bool = false
  @AppStorage("showsMuteButton") var showsMuteButton: Bool = false
  @AppStorage("usesSliderSteps") var usesSliderSteps: Bool = false
  
  init() {}
  
  init(controls: Controls) {
    self.controls = controls
  }
}

enum Controls: String {
  case slider
  case buttons
}

@main
struct VolumeRemoteApp: App {
  @StateObject var settings = AppSettings()
  @StateObject var network = Network()

  var body: some Scene {
#if os(iOS)
    WindowGroup {
      NavigationView {
        DevicesView(
          devices: Array(network.devices.values),
          networkIsReachable: network.isReachable
        )
          .environmentObject(settings)
          .environmentObject(network)
      }
    }
#elseif os(macOS)
    WindowGroup {
      VStack(spacing: 15) {
        DeviceIcon()
          .padding(.bottom, 5)
        
        Text("hi, and welcome to Volume Remote")
          .font(.title2.weight(.medium))
        
        Text("connect from your iPhone to get started")
          .foregroundStyle(.secondary)
      }
      .multilineTextAlignment(.center)
      .frame(width: 300)
      .padding()
      .padding()
    }
#else
    _EmptyScene()
#endif
  }
}

struct NoConnection: View {
  var body: some View {
    VStack(spacing: 10) {
      Image(systemName: "wifi")
        .font(.system(size: 56))
      
      Text("No Connection")
        .font(.title2.weight(.medium))
      
      Text("To use the Volume Remote app, connect your device to a Wi-Fi network.")
    }
    .foregroundStyle(.secondary)
    .multilineTextAlignment(.center)
    .frame(maxWidth: 300)
  }
}

struct NoConnection_Previews: PreviewProvider {
  static var previews: some View {
    NoConnection()
      .padding()
      .previewLayout(.sizeThatFits)
  }
}

struct NoDevices: View {
  var body: some View {
    VStack(spacing: 10) {
      DeviceIcon(disabled: true)
        .padding(.bottom, 5)
      
      Text("No Devices Found")
        .font(.title2.weight(.medium))
      
      Text("Open Volume Remote on your Mac to get started.")
    }
    .foregroundStyle(.secondary)
    .multilineTextAlignment(.center)
    .frame(maxWidth: 300)
  }
}

struct NoDevices_Previews: PreviewProvider {
  static var previews: some View {
    NoDevices()
      .padding()
      .previewLayout(.sizeThatFits)
  }
}

struct ConnectingToDevice: View {
  var body: some View {
    VStack(spacing: 10) {
      DeviceIcon()
        .padding(.bottom, 5)
      
      Text("Connecting to device…")
    }
    .foregroundStyle(.secondary)
    .multilineTextAlignment(.center)
    .frame(maxWidth: 300)
  }
}

struct ConnectingToDevice_Previews: PreviewProvider {
  static var previews: some View {
    ConnectingToDevice()
      .padding()
      .previewLayout(.sizeThatFits)
  }
}

#if os(iOS)

//struct ServiceBrowser: UIViewControllerRepresentable {
//  let session: MCSession
//
//  func makeUIViewController(context: Context) -> MCBrowserViewController {
////    let browser = MCNearbyServiceBrowser(peer: , serviceType: )
////    browser.delegate?.brow
////    browser.startBrowsingForPeers()
////let peer = MCPeerID(displayName: "")
////session.connec
//
//    let controller = MCBrowserViewController(serviceType: SERVICE_TYPE, session: session)
//    controller.minimumNumberOfPeers = 1
//    controller.maximumNumberOfPeers = 1
//    controller.delegate = context.coordinator
//    // controller.startBrowsingForPeers()
//    return controller
//  }
//
//  func updateUIViewController(_ viewController: MCBrowserViewController, context: Context) {}
//
//  func makeCoordinator() -> Coordinator {
//    Coordinator()
//  }
//
//  class Coordinator: NSObject, MCBrowserViewControllerDelegate {
//    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
//      print((#function))
//    }
//
//    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
//      print((#function))
//    }
//
//    func browserViewController(_ browserViewController: MCBrowserViewController, shouldPresentNearbyPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) -> Bool {
//      print((#function, peerID, info))
//      return true
//    }
//  }
//
////  class Coordinator: NSObject, MCNearbyServiceBrowserDelegate {
////    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
////      print(#function)
////    }
////
////    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
////      print(#function)
////    }
////
////    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
////      print(#function)
////    }
////  }
//}
#endif
