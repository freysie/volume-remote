import SwiftUI

struct SettingsView: View {
  @EnvironmentObject var settings: AppSettings
  // @State var stayConnected = false

  var body: some View {
    Form {
      Toggle("Fade Bezel", isOn: settings.$fadesBezel)
      Toggle("Show Mute Button", isOn: settings.$showsMuteButton)

      Picker("Control Using", selection: settings.$controls.animation()) {
        Text("Slider").tag(Controls.slider)
        Text("Buttons").tag(Controls.buttons)
      }
      .pickerStyle(.inline)

      if settings.controls == .slider {
        Toggle("Slider Steps", isOn: settings.$usesSliderSteps)
      }

      // Section {
      //   Toggle("Stay Connected", isOn: $stayConnected)
      // } footer: {
      //   Text("Staying connected speeds up wake time, but may decrease battery life.")
      // }
    }
    .navigationTitle("Settings")
    .navigationBarTitleDisplayMode(.inline)
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      SettingsView()
        .environmentObject(AppSettings(controls: .slider))
    }

    NavigationView {
      SettingsView()
        .environmentObject(AppSettings(controls: .buttons))
    }
  }
}
