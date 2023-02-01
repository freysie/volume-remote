import SwiftUI

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
  @Environment(\.dismiss) var dismiss

  var body: some View {
    VStack(spacing: 10) {
      DeviceIcon()
        .padding(.bottom, 5)
      
      Text("Connecting to device…")
    }
    .foregroundStyle(.secondary)
    .multilineTextAlignment(.center)
    .frame(maxWidth: 300)
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button("Cancel", action: { dismiss() })
      }
    }
  }
}

struct ConnectingToDevice_Previews: PreviewProvider {
  static var previews: some View {
    ConnectingToDevice()
      .padding()
      .previewLayout(.sizeThatFits)
  }
}
