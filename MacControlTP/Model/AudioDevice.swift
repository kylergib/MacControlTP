//
//  AudioDevice.swift
//  MacControlTP
//
//  Created by kyle on 3/9/24.
// had a bunch of help from figuring things out from: https://github.com/karaggeorge/macos-audio-devices/blob/5b5db178bc01a019fb4865bae083a0b9b4fdb0d4/Sources/audio-devices/AudioDevices.swift#L206
//
import AudioToolbox
import Cocoa
import CoreAudio
import Foundation
import TPSwiftSDK

public class AudioDevice {
    public static var outputDevices = [String: AudioDevice]()
    public static var inputDevices = [String: AudioDevice]()
    public static var outputDeviceNameToId = [String: AudioDeviceID]()
    public static var inputDeviceNameToId = [String: AudioDeviceID]()
    public static var defaultOutput: AudioDevice?
    public static var defaultInput: AudioDevice?
    public var id: AudioDeviceID
    public var name: CFString
    public var deviceUID: CFString
    public var hasVolume: Bool
    public var transportType: UInt32?
    public var volume: Float32?
    public var isInput: Bool = false
    public var isOutput: Bool = false
    public static var outputTimer: Timer?
    

//    public static var defaultDeviceOutputVolume: Float32 = 0

    public init(id: AudioDeviceID, name: CFString, deviceUID: CFString, hasVolume: Bool, transportType: UInt32? = nil, volume: Float32?) {
        self.id = id
        self.name = name
        self.deviceUID = deviceUID
        self.hasVolume = hasVolume
        self.transportType = transportType
        self.volume = volume
    }

    static func createDevice(id: AudioDeviceID) -> AudioDevice? {
        var volume: Float32?
        if let uid = AudioDevice.getDeviceUID(id: id), let name = AudioDevice.getDeviceName(id: id) {

            let isInput = isInput(id: id)
            let isOutput = isOutput(id: id)

            let hasVolume = AudioDevice.hasVolume(id: id, isInput: isInput)
            if hasVolume { volume = AudioDevice.getVolume(id: id, isInput: isInput) }
            let trasportType = AudioDevice.getTransportType(id: id)
            let device = AudioDevice(id: id, name: name, deviceUID: uid, hasVolume: hasVolume, transportType: trasportType, volume: volume)
            device.isInput = isInput
            device.isOutput = isOutput

            if isInput { AudioDevice.inputDevices["\(id)"] = device }
            if isOutput { AudioDevice.outputDevices["\(id)"] = device }
            return device
        }
        return nil
    }

    static func setupOutputDeviceChangeListener(isOutput: Bool) {
        let propertyListenerBlock: AudioObjectPropertyListenerBlock = { (numberAddresses: UInt32, addresses: UnsafePointer<AudioObjectPropertyAddress>) in
            for i in 0 ..< Int(numberAddresses) {
                var address = addresses[i]
                switch address.mSelector {
                case kAudioHardwarePropertyDefaultOutputDevice:
//                    print("Default output device changed.")
                    // Perform actions here, such as updating UI or reconfiguring audio sessions
                    // You can retrieve the new default device ID similar to how it's done in the setupListener function
                    var newDefaultDeviceId = AudioObjectID()
                    var propertySize = UInt32(MemoryLayout.size(ofValue: newDefaultDeviceId))
                    let status = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &propertySize, &newDefaultDeviceId)

                    if status == noErr {

                        if !outputDevices.keys.contains("\(newDefaultDeviceId)") {
                            defaultOutput = AudioDevice.createDevice(id: newDefaultDeviceId)
                        } else {
                            defaultOutput = outputDevices["\(newDefaultDeviceId)"]
                            if defaultOutput != nil && defaultOutput!.hasVolume {
                                defaultOutput?.volume = getVolume(id: newDefaultDeviceId)
                            }
                        }
                        if defaultOutput == nil { return }
                        AudioDevice.setupDeviceVolumeListener(deviceId: newDefaultDeviceId, isOutput: true)
                        Connector.updateConnectorData(connectorId: "defaultOutputVolumeConnector", value: Int((defaultOutput!.volume ?? 0) * 100))
                        State.updateState(stateId: "defaultOutputVolumeState", value: "\((defaultOutput!.volume ?? 0) * 100)")
                        State.updateState(stateId: "defaultOutputNameState", value: "\(defaultOutput!.name)")
                    } else {
                        print("Error retrieving new default device ID")
                    }
                case kAudioHardwarePropertyDefaultInputDevice:
//                    print("Default input device changed.")
                    // Perform actions here, such as updating UI or reconfiguring audio sessions
                    // You can retrieve the new default device ID similar to how it's done in the setupListener function
                    var newDefaultDeviceId = AudioObjectID()
                    var propertySize = UInt32(MemoryLayout.size(ofValue: newDefaultDeviceId))
                    let status = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &propertySize, &newDefaultDeviceId)

                    if status == noErr {

                        if !inputDevices.keys.contains("\(newDefaultDeviceId)") {
                            defaultInput = AudioDevice.createDevice(id: newDefaultDeviceId)
                        } else {
                            defaultInput = inputDevices["\(newDefaultDeviceId)"]
                            if defaultInput != nil && defaultInput!.hasVolume {
                                defaultInput?.volume = getVolume(id: newDefaultDeviceId, isInput: true)
                            }
                        }
                        if defaultInput == nil { return }
                        AudioDevice.setupDeviceVolumeListener(deviceId: newDefaultDeviceId, isOutput: false)
                        Connector.updateConnectorData(connectorId: "defaultInputVolumeConnector", value: Int((defaultInput!.volume ?? 0) * 100))
                        State.updateState(stateId: "defaultInputVolumeState", value: "\((defaultInput!.volume ?? 0) * 100)")
                        State.updateState(stateId: "defaultInputNameState", value: "\(defaultInput!.name)")
                    } else {
                        print("Error retrieving new default device ID")
                    }
                default:
                    break
                }
            }
        }

        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: isOutput ? kAudioHardwarePropertyDefaultOutputDevice : kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )


        let status = AudioObjectAddPropertyListenerBlock(AudioObjectID(kAudioObjectSystemObject), &propertyAddress, DispatchQueue.main, propertyListenerBlock)

        if status != noErr {
            print("Error setting up listener for default output device changes")
        }
    }

    // a listener that happens when a device volume is changed, needs to be called every time the default device is changed.
    static func setupDeviceVolumeListener(deviceId: AudioObjectID, isOutput: Bool) {
        var id = deviceId
        let propertyListenerBlock: AudioObjectPropertyListenerBlock
        propertyListenerBlock = { (numberAddresses: UInt32, _: UnsafePointer<AudioObjectPropertyAddress>) in
            for _ in 0 ..< numberAddresses {
                isOutput ? outputVolumeChanged(id: id) : inputVolumeChanged(id: id)
            }
        }

        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: isOutput ? kAudioHardwarePropertyDefaultOutputDevice : kAudioHardwarePropertyDefaultInputDevice,
            mScope: isOutput ? kAudioDevicePropertyScopeOutput : kAudioDevicePropertyScopeInput,
            mElement: kAudioObjectPropertyElementMain
        )

        var propertySize = UInt32(MemoryLayout.size(ofValue: id))

        let status = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &propertyAddress, 0, nil, &propertySize, &id)

        guard status == noErr else {
            print("Error getting default output device ID")
            return
        }

        // Set up a listener for volume changes
        propertyAddress.mSelector = kAudioHardwareServiceDeviceProperty_VirtualMainVolume

        AudioObjectAddPropertyListenerBlock(id, &propertyAddress, DispatchQueue.main, propertyListenerBlock)
    }

    static func outputVolumeChanged(id: AudioDeviceID) {

        if outputDevices.keys.contains("\(id)") {
            let device = outputDevices["\(id)"]
            if device == nil { return }
            let volume = AudioDevice.getVolume(id: id)
            if volume != device?.volume {
                device?.volume = volume
            }

            if defaultOutput?.id == device!.id {
                //                        AudioDevice.defaultDeviceOutputVolume = volume
                if (AudioDevice.outputTimer == nil) {
                    AudioDevice.outputTimer = Timer(timeToWait: 0.5)
                    AudioDevice.outputTimer?.startTimer()
                } else {
                    AudioDevice.outputTimer?.resetTimer()

                }
                
                AudioDevice.outputTimer?.timerFinished = {
                    
                    Connector.updateConnectorData(connectorId: "defaultOutputVolumeConnector", value: Int(volume * 100))
                    State.updateState(stateId: "defaultOutputVolumeState", value: "\(volume * 100)")
                    AudioDevice.outputTimer = nil;
                }
                
                
            }
        }
    }

    static func inputVolumeChanged(id: AudioDeviceID) {
        if inputDevices.keys.contains("\(id)") {
            let device = inputDevices["\(id)"]
            if device == nil { return }
            let volume = AudioDevice.getVolume(id: id, isInput: true)
            if volume != device?.volume {
                device?.volume = volume
            }

            if defaultInput?.id == device!.id {
    
                Connector.updateConnectorData(connectorId: "defaultInputVolumeConnector", value: Int(volume * 100))
                State.updateState(stateId: "defaultInputVolumeState", value: "\(volume * 100)")
            }
        }
    }

   

    static func getDefaultOutputInit() {
        let id = getDefaultOutput()
        var volume: Float32?
        if hasVolume(id: id) {
            volume = getVolume(id: id)
        }
        if outputDevices.keys.contains("\(id)") {
            defaultOutput = outputDevices["\(id)"]

        } else {
            defaultOutput = createDevice(id: id)
        }
        AudioDevice.setupDeviceVolumeListener(deviceId: id, isOutput: true)
        Connector.updateConnectorData(connectorId: "defaultOutputVolumeConnector", value: Int((volume ?? 0) * 100))
        State.updateState(stateId: "defaultOutputVolumeState", value: "\((volume ?? 0) * 100)")
        if defaultOutput != nil { State.updateState(stateId: "defaultOutputNameState", value: "\(defaultOutput!.name)") }
    }

    static func getDefaultInputInit() {
        let id = getDefaultInput()
        var volume: Float32?
        if hasVolume(id: id, isInput: true) {
            volume = getVolume(id: id, isInput: true)
        }

        defaultInput = inputDevices.keys.contains("\(id)") ? inputDevices["\(id)"] : createDevice(id: id)

        AudioDevice.setupDeviceVolumeListener(deviceId: id, isOutput: false)
        Connector.updateConnectorData(connectorId: "defaultInputVolumeConnector", value: Int((volume ?? 0) * 100))
        State.updateState(stateId: "defaultInputVolumeState", value: "\((volume ?? 0) * 100)")
        if defaultInput != nil { State.updateState(stateId: "defaultInputNameState", value: "\(defaultInput!.name)") }
    }

    static func getDefaultOutput() -> AudioDeviceID {
        var defaultOutputDeviceID: AudioDeviceID = 0
        do {
            try CoreAudioData.get(selector: kAudioHardwarePropertyDefaultOutputDevice, value: &defaultOutputDeviceID)

        } catch {
            print(error)
        }
        return defaultOutputDeviceID
    }

    static func getDefaultInput() -> AudioDeviceID {
        var defaultInputDeviceID: AudioDeviceID = 0
        do {
            try CoreAudioData.get(selector: kAudioHardwarePropertyDefaultInputDevice, value: &defaultInputDeviceID)

        } catch {
            print(error)
        }
        return defaultInputDeviceID
    }

    static func setOutput(id: AudioDeviceID) -> Bool {
        var deviceId = id
        do {
            try CoreAudioData.set(
                id: AudioObjectID(kAudioObjectSystemObject),
                selector: kAudioHardwarePropertyDefaultOutputDevice,
                value: &deviceId
            )
            return true
        } catch {
            print(error)
        }
        return false
    }

    static func setInput(id: AudioDeviceID) -> Bool {
        var deviceId = id
        do {
            try CoreAudioData.set(
                id: AudioObjectID(kAudioObjectSystemObject),
                selector: kAudioHardwarePropertyDefaultInputDevice,
                value: &deviceId
            )
            return true
        } catch {
            print(error)
        }
        return false
    }

    static func setVolume(id: AudioDeviceID, volume: Float32, isOutput: Bool = true) -> Bool {
        var value = Float32(volume)
        do {
            try CoreAudioData.set(
                id: id,
                selector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
                scope: isOutput ? kAudioDevicePropertyScopeOutput : kAudioDevicePropertyScopeInput,
                value: &value
            )
            return true
        } catch {
            print(error)
        }
        return false
    }

    static func getVolume(id: AudioDeviceID, isInput: Bool = false) -> Float32 {
        var deviceVolume: Float32 = 0
        do {
            try CoreAudioData.get(
                id: id,
                selector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
                scope: isInput ? kAudioDevicePropertyScopeInput : kAudioDevicePropertyScopeOutput,
                value: &deviceVolume
            )

        } catch {
            print("could not get volume")
        }
        return deviceVolume
    }

    static func hasVolume(id: AudioDeviceID, isInput: Bool = false) -> Bool {
        let hasVolume = CoreAudioData.has(
            id: id,
            selector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
            scope: isInput ? kAudioDevicePropertyScopeInput : kAudioDevicePropertyScopeOutput
        )
        return hasVolume
    }

    static func getTransportType(id: AudioDeviceID) -> UInt32 {
        var deviceTransportType: UInt32 = 0
        do {
            try CoreAudioData.get(
                id: id,
                selector: kAudioDevicePropertyTransportType,
                value: &deviceTransportType
            )
        } catch {
            deviceTransportType = 0
        }
        return deviceTransportType
    }

    static func getAllDevices() -> [AudioDeviceID] {
        do {
            let devicesSize = try CoreAudioData.size(selector: kAudioHardwarePropertyDevices)
            let devicesLength = devicesSize / UInt32(MemoryLayout<AudioDeviceID>.size)
            var deviceIds: [AudioDeviceID] = Array(repeating: 0, count: Int(devicesLength))

            try CoreAudioData.get(
                selector: kAudioHardwarePropertyDevices,
                initialSize: devicesSize,
                value: &deviceIds
            )

            return deviceIds
        } catch {
            print(error)
        }
        return []
    }

    static func isOutput(id: AudioDeviceID) -> Bool {
        do {
            return try CoreAudioData.size(id: id, selector: kAudioDevicePropertyStreams, scope: kAudioDevicePropertyScopeOutput) > 0

        } catch {
            print(error)
        }

        return false
    }

    static func isInput(id: AudioDeviceID) -> Bool {
        do {
            return try CoreAudioData.size(id: id, selector: kAudioDevicePropertyStreams, scope: kAudioDevicePropertyScopeInput) > 0
        } catch {
            print(error)
        }

        return false
    }

    static func getDeviceName(id: AudioDeviceID) -> CFString? {
        do {
            var deviceName = "" as CFString
            try CoreAudioData.get(id: id, selector: kAudioObjectPropertyName, value: &deviceName)
            return deviceName
        } catch {
            print(error)
        }
        return nil
    }

    static func getDeviceUID(id: AudioDeviceID) -> CFString? {
        do {
            var deviceUID = "" as CFString
            try CoreAudioData.get(id: id, selector: kAudioDevicePropertyDeviceUID, value: &deviceUID)
            return deviceUID
        } catch {
            print(error)
        }
        return nil
    }
}
