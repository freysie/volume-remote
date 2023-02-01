import SwiftUI
import AudioToolbox

struct RemoteView: View {
  var device: RemoteDevice

  @State var sliderValue = 0.5
  @State var bezelIsVisible = true
  @State var bezelTimer: Timer?
  @State var settingsArePresented = false
  @State var feedbackSoundID = SystemSoundID(0)
  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var settings: AppSettings
  @EnvironmentObject var network: Network

  func set(_ value: Double) {
    network.send(.setBrightness(Float(value)), to: [device])
    playFeedbackSoundIfNeeded()
    showBezelIfNeeded()
  }

  func decrease() {
    network.send(.decreaseBrightness, to: [device])
    playFeedbackSoundIfNeeded()
    showBezelIfNeeded()
  }
  
  func increase() {
    network.send(.increaseBrightness, to: [device])
    playFeedbackSoundIfNeeded()
    showBezelIfNeeded()
  }
  
  func playFeedbackSoundIfNeeded() {
    guard settings.playsFeedback else { return }
    if feedbackSoundID == 0, let url = Bundle.main.url(forResource: "volume", withExtension: "aiff") {
      AudioServicesCreateSystemSoundID(url as CFURL, &feedbackSoundID)
    }
    AudioServicesPlaySystemSound(feedbackSoundID)
  }
  
  func showBezelIfNeeded() {
    guard settings.fadesBezel else { return }
    bezelIsVisible = true
  }
  
  func hideBezelIfNeeded() {
    guard settings.fadesBezel else { return }
    bezelTimer?.invalidate()
    bezelTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
      bezelIsVisible = false
    }
  }
  
  var body: some View {
    VStack(spacing: 50) {
      Spacer()
      
      Bezel(value: device.brightness)
        .opacity(bezelIsVisible || !settings.fadesBezel ? 1 : 0)
        .animation(Animation.easeOut(duration: bezelIsVisible ? 0 : 0.75), value: bezelIsVisible)
        .onAppear { hideBezelIfNeeded() }
        .onChange(of: bezelIsVisible) { isVisible in
          if isVisible { hideBezelIfNeeded() }
        }
      
      switch settings.controls {
      case .slider:
        VStack(spacing: 40) {
          Group {
            if settings.usesSliderSteps {
              Slider(value: $sliderValue, in: 0.0...1.0, step: 1/16) {
                Text("Brightness")
              } minimumValueLabel: {
                Image(systemName: "speaker")
              } maximumValueLabel: {
                Image(systemName: "speaker.wave.3")
              }
            } else {
              Slider(value: $sliderValue) {
                Text("Brightess")
              } minimumValueLabel: {
                Image(systemName: "speaker")
              } maximumValueLabel: {
                Image(systemName: "speaker.wave.3")
              } onEditingChanged: { _ in
                // print(_)
                set(sliderValue)
              }
            }
          }
          .onChange(of: device.brightness) {
            sliderValue = Double($0)
          }
        }
        .padding(30)
        
      case .buttons:
        HStack {
          Button(action: decrease) {
            Image(systemName: "sun.min")
              .frame(maxWidth: .infinity)
              .frame(height: 48)
          }
          
          Button(action: increase) {
            Image(systemName: "sun.max")
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
    .onChange(of: device.brightness) { _ in showBezelIfNeeded() }
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
