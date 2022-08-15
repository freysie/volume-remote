import SwiftUI

struct RemoteView: View {
  var device: RemoteDevice

  @State var sliderValue = 0.5
  @State var settingsArePresented = false
  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var settings: AppSettings
  @EnvironmentObject var network: Network
  
//  var sliderValue: Binding<Double> {
//    Binding {
//      device.volume
//    } set: { newValue, transaction in
//      network.send(.setVolume(newValue), to: [device])
//    }
//  }
  
  var body: some View {
    VStack(spacing: 50) {
      Spacer()
      
      Bezel(value: device.isMuted ? 0 : device.volume)
      
      switch settings.controls {
      case .slider:
        VStack(spacing: 40) {
          Group {
            if settings.usesSliderSteps {
              Slider(value: $sliderValue, in: 0.0...1.0, step: 1/16) {
                Text("Volume")
              } minimumValueLabel: {
                Image(systemName: "speaker")
              } maximumValueLabel: {
                Image(systemName: "speaker.wave.3")
              }
            } else {
              Slider(value: $sliderValue) {
                Text("Volume")
              } minimumValueLabel: {
                Image(systemName: "speaker")
              } maximumValueLabel: {
                Image(systemName: "speaker.wave.3")
              } onEditingChanged: { wut in
                print(wut)
                network.send(.setVolume(sliderValue), to: [device])
              }
            }
          }
          .onChange(of: device.volume) {
            sliderValue = $0
          }
          
          if settings.showsMuteButton {
            Button(action: { network.send(.toggleMute, to: [device]) }) {
              Image(systemName: "speaker.slash")
                .frame(maxWidth: .infinity)
                .frame(height: 48)
            }
            .font(.system(size: 24))
            .buttonStyle(.bordered)
          }
        }
        .padding(30)
        
      case .buttons:
        HStack {
          if settings.showsMuteButton {
            Button(action: { network.send(.toggleMute, to: [device]) }) {
              Image(systemName: "speaker")
                .frame(maxWidth: .infinity)
                .frame(height: 48)
            }
          }
          
          Button(action: { network.send(.decreaseVolume, to: [device]) }) {
            Image(systemName: "speaker.wave.1")
              .frame(maxWidth: .infinity)
              .frame(height: 48)
          }
          
          Button(action: { network.send(.inceaseVolume, to: [device]) }) {
            Image(systemName: "speaker.wave.3")
              .frame(maxWidth: .infinity)
              .frame(height: 48)
          }
        }
        .font(.system(size: 24))
        .buttonStyle(.bordered)
        .padding(30)
      }
      
      Spacer()
    }
//    .background {
//      Image(uiImage: UIImage(contentsOfFile: "/Users/Freya/Desktop/Screen Shot 2022-08-16 at 2.53.32 AM.png")!)
//    }
    .navigationTitle(device.name)
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarBackButtonHidden(true)
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button(action: { dismiss() }) {
          Text("Devices")
        }
      }
    }
    .toolbar {
      Button(action: { settingsArePresented = true }) {
        Image(systemName: "gearshape")
      }
    }
    .sheet(isPresented: $settingsArePresented) {
      NavigationView {
        SettingsView()
          .toolbar {
            ToolbarItem(placement: .confirmationAction) {
              Button(action: { settingsArePresented = false }) {
                Text("Done")
              }
            }
          }
      }
    }
//    .onChange(of: device) {
//      value = device?.volume
//      isMuted = device?.isMuted
//    }
  }
}

struct RemoteView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      RemoteView(device: RemoteDevice("iMac"))
    }
    .previewDisplayName("Default")
    
    NavigationView {
      RemoteView(device: RemoteDevice("iMac"))
        .environmentObject(AppSettings(controls: .buttons))
    }
    .previewDisplayName("Control Using Buttons")
  }
}
