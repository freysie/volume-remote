import SwiftUI

struct Bezel: View {
  var value: Double
  
  var body: some View {
    VStack(alignment: .center) {
      Spacer()
      
//      Image(systemName: "sun.max")
//        .font(.system(size: 112))
//        .foregroundStyle(.secondary)
      
      Image(systemName: value > 0 ? "speaker.wave.3" : "speaker.slash")
        .font(.system(size: 88))
        .symbolVariant(.fill)
        .foregroundStyle(.secondary)
      
      Spacer()
      
      HStack(spacing: 1) {
        ForEach(0..<16) { i in
          // HStack(spacing: 0) {}
          Rectangle()
            .fill(Double(i) < (16 * value) ? AnyShapeStyle(.secondary) : AnyShapeStyle(.clear))
            .frame(width: 12, height: 8)
        }
      }
      .padding(1)
      .background {
        Rectangle()
          .fill(.quaternary)
      }
      .fixedSize()
      .padding(.all.subtracting(.top), 20)
    }
    .background {
      RoundedRectangle(cornerRadius: 27)
        .fill(.bar)
    }
    //.fixedSize()
    .frame(width: 240, height: 240)
  }
}

struct Bezel_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      Bezel(value: 0)
        .previewDisplayName("0%")
      
      Bezel(value: 0.42)
        .previewDisplayName("42%")
      
      Bezel(value: 1)
        .previewDisplayName("100%")
    }
    .padding()
    .background { Color.gray }
    .previewLayout(.sizeThatFits)
  }
}
