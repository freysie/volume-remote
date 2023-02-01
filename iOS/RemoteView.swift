import SwiftUI
import AudioToolbox

struct RemoteView: View {
  var device: RemoteDevice

  // @State var volume = 0.5
  @State var sliderValue = 0.5
  @State var bezelIsVisible = true
  @State var bezelTimer: Timer?
  @State var settingsArePresented = false
  @State var feedbackSoundID = SystemSoundID(0)
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

  func set(_ value: Double) {
    network.send(.setVolume(value), to: [device])
    playFeedbackSoundIfNeeded()
    showBezelIfNeeded()
  }

  func mute() {
    network.send(.toggleMute, to: [device])
    if device.isMuted { playFeedbackSoundIfNeeded() }
    showBezelIfNeeded()
  }

  func decrease() {
    // volume -= 1/16
    network.send(.decreaseVolume, to: [device])
    playFeedbackSoundIfNeeded()
    showBezelIfNeeded()
  }

  func increase() {
    // volume += 1/16
    network.send(.increaseVolume, to: [device])
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

      Bezel(value: device.isMuted ? 0 : device.volume)
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
              } onEditingChanged: { _ in
                // print(_)
                set(sliderValue)
              }
            }
          }
          .onChange(of: device.volume) {
            sliderValue = $0
          }

          if settings.showsMuteButton {
            Button(action: mute) {
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
            Button(action: mute) {
              Image(systemName: "speaker")
                .frame(maxWidth: .infinity)
                .frame(height: 48)
            }
          }

          Button(action: decrease) {
            Image(systemName: "speaker.wave.1")
              .frame(maxWidth: .infinity)
              .frame(height: 48)
          }

          Button(action: increase) {
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
    .onChange(of: device.volume) { _ in showBezelIfNeeded() }
    .onChange(of: device.isMuted) { _ in showBezelIfNeeded() }
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
