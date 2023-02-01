import SwiftUI

@main
struct VolumeRemoteApp: App {
  @StateObject var settings = AppSettings()
  @StateObject var network = Network()

  init() {
#if os(iOS)
    let defaultAppearance = UINavigationBarAppearance()
    defaultAppearance.configureWithDefaultBackground()
    UINavigationBar.appearance()
      .scrollEdgeAppearance = defaultAppearance

    let transparentAppearance = UINavigationBarAppearance()
    transparentAppearance.configureWithTransparentBackground()
    UINavigationBar.appearance(whenContainedInInstancesOf: [UISheetPresentationController.self])
      .scrollEdgeAppearance = transparentAppearance
#endif
  }

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
        
        Text("Volume Remote")
          .font(.title2.weight(.medium))
        
        Text("Connect from your iPhone to get started.")
          .foregroundStyle(.secondary)
      }
      .navigationTitle("")
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
