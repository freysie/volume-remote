import SwiftUI

class AppSettings: ObservableObject {
  @AppStorage("controls") var controls: Controls = .slider
  @AppStorage("fadesBezel") var fadesBezel: Bool = false
  @AppStorage("showsMuteButton") var showsMuteButton: Bool = false
  @AppStorage("playsFeedback") var playsFeedback: Bool = true
  @AppStorage("usesSliderSteps") var usesSliderSteps: Bool = false
  //@AppStorage("staysConnected") var staysConnected: Bool = false
  
  init() {}
  
  init(controls: Controls) {
    self.controls = controls
  }
}

enum Controls: String {
  case slider
  case buttons
}
