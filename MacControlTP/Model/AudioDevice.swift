//
//  AudioDevice.swift
//  MacControlTP
//
//  Created by kyle on 3/9/24.
//
import Foundation
import AudioToolbox
import CoreAudio

public class AudioDevice {
    public var id: AudioDeviceID
    public var name: CFString
    public var deviceUID: CFString
    public var hasVolume: Bool
    public var transportType: UInt32?
    public var volume: Float32?
    
    public static var defaultDeviceOutputVolume: Float32 = 0

    public init(id: AudioDeviceID, name: CFString, deviceUID: CFString, hasVolume: Bool, transportType: UInt32? = nil, volume: Float32?) {
        self.id = id
        self.name = name
        self.deviceUID = deviceUID
        self.hasVolume = hasVolume
        self.transportType = transportType
        self.volume = volume
    }
    static func getDefaultOutput() -> AudioDeviceID {
        var defaultOutputDeviceID: AudioDeviceID = 0
        do {
            try CoreAudioData.get(selector: kAudioHardwarePropertyDefaultOutputDevice, value: &defaultOutputDeviceID)
//            print("Default audio ID is \(defaultOutputDeviceID)")
        } catch {
            print(error)
        }
        return defaultOutputDeviceID
    }
    // AudioDeviceID = 0 will set default to volume
    static func setVolume(id: AudioDeviceID = getDefaultOutput(), volume: Float32) -> Bool {
        var value = Float32(volume)
        do {
            try CoreAudioData.set(
                id: id,
                selector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
                scope: kAudioDevicePropertyScopeOutput,
                value: &value
            )
            return true
        } catch {
            print(error)
        }
        return false
    }

    static func getVolume(id: AudioDeviceID = getDefaultOutput()) -> Float32 {
        var deviceVolume: Float32 = 0
        do {
            try CoreAudioData.get(
                id: id,
                selector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
                scope: kAudioDevicePropertyScopeOutput,
                value: &deviceVolume
            )

//            print(deviceVolume)
        } catch {
            print("could not get volume")
        }
        return deviceVolume
    }

    static func hasVolume(id: AudioDeviceID) -> Bool {
        let hasVolume = CoreAudioData.has(
            id: id,
            selector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
            scope: kAudioDevicePropertyScopeOutput
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
