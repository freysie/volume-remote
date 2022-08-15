import SwiftUI
import MultipeerConnectivity
#if os(macOS)
@testable import ISSoundAdditions
#endif

struct DevicesView: View {
  var devices = [RemoteDevice]()
  var networkIsReachable = true
  @EnvironmentObject var settings: AppSettings
  @EnvironmentObject var network: Network
  
  var body: some View {
    Group {
      if !networkIsReachable {
        NoConnection()
          .padding(.bottom, 64)
      } else if devices.isEmpty {
        NoDevices()
          .padding(.bottom, 64)
      } else {
        ScrollView {
          Spacer(minLength: 12)
        
          ForEach(devices) { device in
            NavigationLink {
              if device.isConnected {
                RemoteView(device: device)
                  .environmentObject(network)
                  .environmentObject(settings)
              } else {
                ConnectingToDevice()
                  .onAppear { network.connect(device) }
              }
            } label: {
              VStack(spacing: 10) {
                DeviceIcon()
                
                Text(device.name)
                  .foregroundColor(.primary)
              }
            }
            .padding()
          }
        }
      }
    }
    .navigationTitle("Volume Remote")
    .navigationBarTitleDisplayMode(.inline)
//    .toolbar {
//      if networkIsReachable {
//        Button(action: { browserIsPresented = true }) {
//          Label("Add", systemImage: "plus")
//        }
//      }
//    }
//    .sheet(isPresented: $browserIsPresented) {
//      if let session = session {
//        ServiceBrowser(session: session)
//          .navigationTitle("Add Device")
//      }
//    }
  }
}

struct DevicesView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      DevicesView(devices: [RemoteDevice("iMac")])
    }
    .previewDisplayName("Default")

    NavigationView {
      DevicesView(devices: [])
    }
    .previewDisplayName("No Devices Found")

    NavigationView {
      DevicesView(networkIsReachable: false)
    }
    .previewDisplayName("No Connection")
  }
}
