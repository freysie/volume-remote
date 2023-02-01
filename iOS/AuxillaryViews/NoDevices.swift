import SwiftUI

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
