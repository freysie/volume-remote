import SwiftUI

#if os(iOS)
let screenScale = UIScreen.main.scale
#elseif os(macOS)
let screenScale = NSScreen.main?.backingScaleFactor ?? 1
#endif

struct DeviceIcon: View {
  var disabled = false

  var body: some View {
    // AngularGradient(
    //   colors: [.blue, .purple, .red, .pink],
    //   center: .center
    // )

    LinearGradient(
      colors: !disabled
      ? [Color(red: 0.38, green: 0.69, blue: 0.95), Color(red: 0.4, green: 0.62, blue: 0.94)]
      : [Color(white: 0.57), Color(white: 0.7)],
      startPoint: .leading,
      endPoint: .trailing
    )
    .mask {
      Image(systemName: "sun.max")
        .font(.system(size: 48).bold())
    }
    .background {
      LinearGradient(
        colors: !disabled
        ? [Color(red: 0.38, green: 0.69, blue: 0.95), Color(red: 0.4, green: 0.62, blue: 0.94)]
        : [Color(white: 0.57), Color(white: 0.7)],
        startPoint: .leading,
        endPoint: .trailing
      )
      .overlay {
        Color.black.opacity(0.3)
      }
      .mask {
        Image(systemName: "sun.max")
          .font(.system(size: 48).bold())
      }
      .offset(x: 0, y: -1 / screenScale)
    }
    .background {
      LinearGradient(
        colors: !disabled
        ? [Color(red: 0.99, green: 1, blue: 1), Color(red: 0.86, green: 0.88, blue: 0.9)]
        : [.white, Color(white: 0.9)],
        startPoint: .top,
        endPoint: .bottom
      )
        .mask {
          Circle()
            .padding(5)
        }
    }
    .background {
      LinearGradient(
        colors: !disabled
        ? [Color(white: 0.96), Color(red: 0.73, green: 0.75, blue: 0.77)]
        : [Color(white: 0.98), Color(white: 0.8)],
        startPoint: .top,
        endPoint: .bottom
      )
        .mask {
          Circle()
        }
    }
    .clipped()
    .shadow(color: Color(white: 0.96), radius: 2)
    .frame(width: 118, height: 118)
    // .drawingGroup()
  }
}

struct DeviceIcon_Previews: PreviewProvider {
  static var previews: some View {
    DeviceIcon()
      .padding()
      .previewLayout(.sizeThatFits)
      .previewDisplayName("Default")
    
    DeviceIcon(disabled: true)
      .padding()
      .previewLayout(.sizeThatFits)
      .previewDisplayName("Disabled")
  }
}
