//
//  CoreAudioData.swift
//  MacControlTP
//
//  Created by kyle on 3/9/24.
//
//import Foundation
import AudioToolbox
//import Cocoa
import CoreAudio

public enum CoreAudioData {
    public static func get<T>(
        id: AudioObjectID = AudioObjectID(kAudioObjectSystemObject),
        selector: AudioObjectPropertySelector,
        scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal,
        element: AudioObjectPropertyElement = kAudioObjectPropertyElementMain,
        initialSize: UInt32 = UInt32(MemoryLayout<T>.size),
        value: UnsafeMutablePointer<T>
    ) throws {
        var address = AudioObjectPropertyAddress(
            mSelector: selector,
            mScope: scope,
            mElement: element
        )

        var propertySize = initialSize

        let status = AudioObjectGetPropertyData(
            id,
            &address,
            0,
            nil,
            &propertySize,
            value
        )

        guard status == noErr else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
        }
    }

    public static func has(
        id: UInt32 = AudioObjectID(kAudioObjectSystemObject),
        selector: AudioObjectPropertySelector,
        scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal,
        element: AudioObjectPropertyElement = kAudioObjectPropertyElementMain
    ) -> Bool {
        var address = AudioObjectPropertyAddress(
            mSelector: selector,
            mScope: scope,
            mElement: element
        )

        return AudioObjectHasProperty(id, &address)
    }

    public static func size(
        id: UInt32 = AudioObjectID(kAudioObjectSystemObject),
        selector: AudioObjectPropertySelector,
        scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal,
        element: AudioObjectPropertyElement = kAudioObjectPropertyElementMain
    ) throws -> UInt32 {
        var size: UInt32 = 0

        var address = AudioObjectPropertyAddress(
            mSelector: selector,
            mScope: scope,
            mElement: element
        )

        let status = AudioObjectGetPropertyDataSize(id, &address, 0, nil, &size)
        guard status == noErr else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
        }

        return size
    }

    public static func set<T>(
        id: UInt32 = AudioObjectID(kAudioObjectSystemObject),
        selector: AudioObjectPropertySelector,
        scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal,
        element: AudioObjectPropertyElement = kAudioObjectPropertyElementMain,
        value: UnsafeMutablePointer<T>
    ) throws {
        let size = UInt32(MemoryLayout<T>.size)
        var address = AudioObjectPropertyAddress(
            mSelector: selector,
            mScope: scope,
            mElement: element
        )

        let status = AudioObjectSetPropertyData(id, &address, 0, nil, size, value)
        guard status == noErr else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
        }
    }
}
