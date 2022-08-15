import AudioToolbox
import CoreAudio
@testable import ISSoundAdditions

extension Sound.SoundOutputManager {
  // FIXME: shouldn’t call block twice
  func addVolumeObserver(_ block: @escaping (Float) -> ()) throws {
    guard let deviceID = Sound.output.defaultOutputDevice else {
      return
    }
    
    var address = AudioObjectPropertyAddress(
      mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
      mScope: kAudioDevicePropertyScopeOutput,
      mElement: kAudioObjectPropertyElementMain
    )
    
    guard AudioObjectHasProperty(deviceID, &address) else {
      throw Errors.unsupportedProperty
    }
    
    let error = AudioObjectAddPropertyListenerBlock(deviceID, &address, nil) { addressCount, addresses in
      for i in 0..<addressCount {
        var address = addresses[Int(i)]
        
        if address.mSelector == kAudioHardwareServiceDeviceProperty_VirtualMainVolume {
          var volume: Float = 0
          var size = UInt32(MemoryLayout<Float32>.size)
          
          let error = AudioObjectGetPropertyData(deviceID, &address, 0, nil, &size, &volume)
          guard error == noErr else {
            print(error)
            continue
          }
          
          block(min(max(0, volume), 1))
          
          break
        }
      }
    }
    
    guard error == noErr else {
      throw Errors.operationFailed(error)
    }
  }

  func addMuteObserver(_ block: @escaping (Bool) -> ()) throws {
    guard let deviceID = Sound.output.defaultOutputDevice else {
      return
    }
    
    var address = AudioObjectPropertyAddress(
      mSelector: kAudioDevicePropertyMute,
      mScope: kAudioDevicePropertyScopeOutput,
      mElement: kAudioObjectPropertyElementMain
    )
    
    guard AudioObjectHasProperty(deviceID, &address) else {
      throw Errors.unsupportedProperty
    }
    
    let error = AudioObjectAddPropertyListenerBlock(deviceID, &address, nil) { addressCount, addresses in
      for i in 0..<addressCount {
        var address = addresses[Int(i)]
        
        if address.mSelector == kAudioDevicePropertyMute {
          var isMuted: UInt32 = 0
          var size = UInt32(MemoryLayout<UInt32>.size(ofValue: isMuted))
          
          let error = AudioObjectGetPropertyData(deviceID, &address, 0, nil, &size, &isMuted)
          guard error == noErr else {
            print(error)
            continue
          }
          
          block(isMuted == 1)
          
          break
        }
      }
    }
    
    guard error == noErr else {
      throw Errors.operationFailed(error)
    }
  }
}
