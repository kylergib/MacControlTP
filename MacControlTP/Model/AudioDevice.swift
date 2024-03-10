//
//  AudioDevice.swift
//  MacControlTP
//
//  Created by kyle on 3/9/24.
//
import AudioToolbox
import CoreAudio
import Foundation
import TPSwiftSDK

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

//    static func audioVolumeChangeListenerBlock(propertyAddress: UnsafePointer<AudioObjectPropertyAddress>,
//                                               dataSize: UInt32,
//                                               data: UnsafeRawPointer) -> OSStatus
//    {
//        let volume = data.assumingMemoryBound(to: Float32.self).pointee
//        print("Volume changed to \(volume)")
//        return noErr
//    }
//    func setupVolumeChangeListener() {
//        var volumeListenerBlock: AudioObjectPropertyListenerBlock = audioVolumeChangeListenerBlock
//        var defaultOutputDeviceID = AudioObjectID(kAudioObjectSystemObject)
//        var defaultOutputDeviceIDSize = UInt32(MemoryLayout.size(ofValue: defaultOutputDeviceID))
//
//        var propertyAddress = AudioObjectPropertyAddress(mSelector: kAudioHardwarePropertyDefaultOutputDevice,
//                                                          mScope: kAudioObjectPropertyScopeGlobal,
//                                                          mElement: kAudioObjectPropertyElementMaster)
//
//        let status = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject),
//                                                &propertyAddress,
//                                                0,
//                                                nil,
//                                                &defaultOutputDeviceIDSize,
//                                                &defaultOutputDeviceID)
//
//        guard status == noErr else {
//            print("Error getting default output device ID")
//            return
//        }
//
//        propertyAddress.mSelector = kAudioHardwareServiceDeviceProperty_VirtualMainVolume
//
//        AudioObjectAddPropertyListenerBlock(defaultOutputDeviceID,
//                                            &propertyAddress,
//                                            DispatchQueue.main,
//                                            volumeListenerBlock)
//    }

    static func setupListener(deviceId: AudioObjectID = 0) {
        var id = deviceId
        let propertyListenerBlock: AudioObjectPropertyListenerBlock
        propertyListenerBlock = { (numberAddresses: UInt32, _: UnsafePointer<AudioObjectPropertyAddress>) in
            for i in 0 ..< numberAddresses {
                // Your handling code here. For example:
                print("Output volume changed.")
                var volume: Float32 = 0.0
                var dataSize = UInt32(MemoryLayout.size(ofValue: volume))
                var volumePropertyAddress = AudioObjectPropertyAddress(
                    mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
                    mScope: kAudioObjectPropertyScopeOutput,
                    mElement: kAudioObjectPropertyElementMain
                )

                AudioObjectGetPropertyData(id, &volumePropertyAddress, 0, nil, &dataSize, &volume)

                print("Output volume changed to \(volume)")
                if (volume != AudioDevice.defaultDeviceOutputVolume) {
                    AudioDevice.defaultDeviceOutputVolume = volume
                    Connector.updateConnectorData(connectorId: "defaultOutputVolumeConnector", value: Int(volume*100))
                }
                
            }
        }
        var volume: Float32 = 0.0
        var dataSize = UInt32(MemoryLayout.size(ofValue: volume))
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioDevicePropertyScopeOutput,
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
