//
//  Actions.swift
//  MacControlTP
//
//  Created by kyle on 3/9/24.
//

import Foundation
import LoggerSwift
import TPSwiftSDK

enum Actions {
    private static var logger = Logger(current: Actions.self)
    static func createActions(plugin: Plugin) {
        createSetDefaultOutputVolumeAction(plugin: plugin)
        createPlayPauseAction(plugin: plugin)
        createPrevAction(plugin: plugin)
        createNextAction(plugin: plugin)
        createSetOutputDevice(plugin: plugin)
        createSetInputDevice(plugin: plugin)
    }
    
    static func createSetDefaultOutputVolumeAction(plugin: Plugin) {
        if !plugin.categories.keys.contains("MacControl") {
            logger.error("Could not find MacControl category")
            return
        }
        let action = Action(id: "setDefaultOutputVolume", name: "Set Default Output Volume", type: ActionType.communicate, category: plugin.categories["MacControl"]!)
        
        action.addData(data: ActionData(id: "defaultOutputVolume", type: ActionDataType.number(0)))
        
        action.addActionLine(actionLine: ActionLine(data: ["Set volume of default output to: {$defaultOutputVolume$}"]))
        
        action.onAction = { response in
            logger.debug("setDefaultOutputVolume - pressed")
            //            print(response.data)
            DispatchQueue.global(qos: .background).async {
                let dataList = response.data
                dataList?.forEach { data in
                    if data.id == "defaultOutputVolume", data.value != nil {
                        if let floatValue = Float(data.value as! String) {
                            _ = AudioDevice.setVolume(id: AudioDevice.getDefaultOutput(), volume: floatValue)
                            // TODO: capture if it was succesful or not
                        } else {
                            logger.error("The string does not contain a valid floating point number")
                        }
                    }
                }
            }
        }
        plugin.addAction(action: action)
    }

    static func createPlayPauseAction(plugin: Plugin) {
        if !plugin.categories.keys.contains("MacControl") {
            logger.error("Could not find MacControl category")
            return
        }
        let action = Action(id: "playPauseKey", name: "Emulate play/pause media key", type: ActionType.communicate, category: plugin.categories["MacControl"]!)
        
        action.addActionLine(actionLine: ActionLine(data: ["Emulate play/pause media key"]))
        action.onAction = { _ in
            logger.debug("playPauseKey pressed")
            DispatchQueue.global(qos: .background).async {
                MediaKey.pressKey(key: MediaKey.playpause.rawValue, down: true)
                MediaKey.pressKey(key: MediaKey.playpause.rawValue, down: false)
            }
        }
    
        plugin.addAction(action: action)
    }
    
    static func createNextAction(plugin: Plugin) {
        if !plugin.categories.keys.contains("MacControl") {
            logger.error("Could not find MacControl category")
            return
        }
        let action = Action(id: "nextMediaKey", name: "Emulate next media key", type: ActionType.communicate, category: plugin.categories["MacControl"]!)
        
//        setDefaultOutputVolume.addData(data: ActionData(id: "defaultOutputVolume", type: ActionDataType.number(0)))
        
        action.addActionLine(actionLine: ActionLine(data: ["Emulate next media key"]))
        action.onAction = { _ in
            //            print(response.data)
            DispatchQueue.global(qos: .background).async {
                logger.debug("nextMediaKey pressed")
                MediaKey.pressKey(key: MediaKey.next.rawValue, down: true)
                MediaKey.pressKey(key: MediaKey.next.rawValue, down: false)
            }
        }
        plugin.addAction(action: action)
    }
    
    static func createPrevAction(plugin: Plugin) {
        if !plugin.categories.keys.contains("MacControl") {
            logger.error("Could not find MacControl category")
            return
        }
        let action = Action(id: "prevMediaKey", name: "Emulate previous media key", type: ActionType.communicate, category: plugin.categories["MacControl"]!)
        
        action.addActionLine(actionLine: ActionLine(data: ["Emulate previous media key"]))
        action.onAction = { _ in
            //            print(response.data)
            DispatchQueue.global(qos: .background).async {
                logger.debug("prevMediaKey pressed")
                MediaKey.pressKey(key: MediaKey.prev.rawValue, down: true)
                MediaKey.pressKey(key: MediaKey.prev.rawValue, down: false)
            }
        }
        plugin.addAction(action: action)
    }

    static func createSetOutputDevice(plugin: Plugin) {
        if !plugin.categories.keys.contains("MacControl") {
            logger.error("Could not find MacControl category")
            return
        }
        let action = Action(id: "setOutputDevice", name: "Set Output device", type: ActionType.communicate, category: plugin.categories["MacControl"]!)
        action.addData(data: ActionData(id: "outputDevices", type: ActionDataType.choice(""), valueChoices: []))
        action.addActionLine(actionLine: ActionLine(data: ["line 1", "Set output device: {$outputDevices$}"]))
        action.onAction = { response in
            //            print(response.data)
            DispatchQueue.global(qos: .background).async {
                logger.debug("setOutputDevice pressed")
                if response.data == nil || !(response.data!.count > 0 || response.data![0].value == nil) { return }
                if let id = AudioDevice.outputDeviceNameToId["\(response.data![0].value!)"] {
                    _ = AudioDevice.setOutput(id: id)
                }
                
//                MediaKey.pressKey(key: MediaKey.prev.rawValue, down: true)
            }
        }
        action.hasHoldFunctionality = true
        action.onUpAction = { _ in
            logger.debug("testid pressed")
        }
        plugin.addAction(action: action)
    }

    static func createSetInputDevice(plugin: Plugin) {
        if !plugin.categories.keys.contains("MacControl") {
            logger.error("Could not find MacControl category")
            return
        }
        let action = Action(id: "setInputDevice", name: "Set Input device", type: ActionType.communicate, category: plugin.categories["MacControl"]!)
        action.addData(data: ActionData(id: "inputDevices", type: ActionDataType.choice(""), valueChoices: []))
        action.addActionLine(actionLine: ActionLine(data: ["Set input device: {$inputDevices$}"]))
        action.onAction = { response in
            //            print(response.data)
            DispatchQueue.global(qos: .background).async {
                logger.debug("setInputDevice pressed")
                if response.data == nil || !(response.data!.count > 0 || response.data![0].value == nil) { return }
                if let id = AudioDevice.inputDeviceNameToId["\(response.data![0].value!)"] {
                    _ = AudioDevice.setInput(id: id)
                }
                   
                //                MediaKey.pressKey(key: MediaKey.prev.rawValue, down: true)
            }
        }
        action.hasHoldFunctionality = true
        action.onUpAction = { _ in
            logger.debug("testid pressed")
        }
        plugin.addAction(action: action)
    }
}
