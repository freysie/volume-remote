import SwiftUI

struct Connecting: View {
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

struct Connecting_Previews: PreviewProvider {
  static var previews: some View {
    Connecting()
      .padding()
      .previewLayout(.sizeThatFits)
  }
}
