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
