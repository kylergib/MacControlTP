//
//  MediaKeys.swift
//  MacControlTP
//
//  Created by kyle on 3/10/24.
//

import Foundation
import Cocoa

enum MediaKey: Int {
    case playpause = 16
    case next = 17
    case prev = 18
    
    static func pressKey(key: Int, down: Bool) {
        let flags = NSEvent.ModifierFlags(rawValue: UInt(down ? 0xA00 : 0xB00))
        let data1 = Int((key << 16) | ((down ? 0xA : 0xB) << 8))
        
        guard let event = NSEvent.otherEvent(with: .systemDefined, location: NSPoint(x: 0, y: 0), modifierFlags: flags, timestamp: TimeInterval(0), windowNumber: 0, context: nil, subtype: 8, data1: data1, data2: -1) else {
            return
        }
        
        let cgEvent = event.cgEvent!
        cgEvent.post(tap: .cghidEventTap)
    }
}
