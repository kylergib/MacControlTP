//
//  Actions.swift
//  MacControlTP
//
//  Created by kyle on 3/9/24.
//

import Foundation
import TPSwiftSDK

enum Actions {
    static func createActions(plugin: Plugin) {
        createSetDefaultOutputVolumeAction(plugin: plugin)
        createPlayPauseAction(plugin: plugin)
        createPrevAction(plugin: plugin)
        createNextAction(plugin: plugin)
        createTestAction(plugin: plugin)
    }
    
    static func createSetDefaultOutputVolumeAction(plugin: Plugin) {
        let action = Action(id: "setDefaultOutputVolume", name: "Set Default Output Volume", type: ActionType.communicate, category: plugin.categories["volume"]!)
        
        action.addData(data: ActionData(id: "defaultOutputVolume", type: ActionDataType.number(0)))
        
        action.addActionLine(actionLine: ActionLine(data: ["Set volume of default output to: {$defaultOutputVolume$}"]))
        
        action.onAction = { response in
            print("action 1")
            //            print(response.data)
            DispatchQueue.global(qos: .background).async {
                let dataList = response.data
                dataList?.forEach { data in
                    if data.id == "defaultOutputVolume", data.value != nil {
                        if let floatValue = Float(data.value as! String) {
                            _ = AudioDevice.setVolume(volume: floatValue)
                            // TODO: capture if it was succesful or not
                        } else {
                            print("The string does not contain a valid floating point number")
                        }
                    }
                }
            }
        }
        plugin.addAction(action: action)
    }

    static func createPlayPauseAction(plugin: Plugin) {
        let action = Action(id: "playPauseKey", name: "Emulate play/pause media key", type: ActionType.communicate, category: plugin.categories["volume"]!)
        
//        setDefaultOutputVolume.addData(data: ActionData(id: "defaultOutputVolume", type: ActionDataType.number(0)))
        
        
        action.addActionLine(actionLine: ActionLine(data: ["Emulate play/pause media key"]))
        action.onAction = { response in
            //            print(response.data)
            DispatchQueue.global(qos: .background).async {
                print("createMediaKeyAction")
                MediaKey.pressKey(key: MediaKey.playpause.rawValue, down: true)
                MediaKey.pressKey(key: MediaKey.playpause.rawValue, down: false)
            }
        }
    
        plugin.addAction(action: action)
    }
    
    static func createNextAction(plugin: Plugin) {
        let action = Action(id: "nextMediaKey", name: "Emulate next media key", type: ActionType.communicate, category: plugin.categories["volume"]!)
        
//        setDefaultOutputVolume.addData(data: ActionData(id: "defaultOutputVolume", type: ActionDataType.number(0)))
        
        
        action.addActionLine(actionLine: ActionLine(data: ["Emulate next media key"]))
        action.onAction = { response in
            //            print(response.data)
            DispatchQueue.global(qos: .background).async {
                print("createMediaKeyAction")
                MediaKey.pressKey(key: MediaKey.next.rawValue, down: true)
                MediaKey.pressKey(key: MediaKey.next.rawValue, down: false)
            }
        }
        plugin.addAction(action: action)
    }
    
    static func createPrevAction(plugin: Plugin) {
        let action = Action(id: "prevMediaKey", name: "Emulate previous media key", type: ActionType.communicate, category: plugin.categories["volume"]!)
        
        action.addActionLine(actionLine: ActionLine(data: ["Emulate previous media key"]))
        action.onAction = { response in
            //            print(response.data)
            DispatchQueue.global(qos: .background).async {
                print("createMediaKeyAction")
                MediaKey.pressKey(key: MediaKey.prev.rawValue, down: true)
                MediaKey.pressKey(key: MediaKey.prev.rawValue, down: false)
            }
        }
        plugin.addAction(action: action)
    }
    static func createTestAction(plugin: Plugin) {
        let action = Action(id: "testid", name: "test", type: ActionType.communicate, category: plugin.categories["volume"]!)
        action.addData(data: ActionData(id: "testdata", type: ActionDataType.choice("200"), valueChoices: ["200", "400", "600", "800"]))
        action.addActionLine(actionLine: ActionLine(data: ["line 1","Testing: {$testdata$}"]))
        action.onAction = { response in
            //            print(response.data)
            DispatchQueue.global(qos: .background).async {
                print("createMediaKeyAction")
                MediaKey.pressKey(key: MediaKey.prev.rawValue, down: true)
            }
        }
        action.onListChange = { response in
            print(response.values)
        }
        plugin.addAction(action: action)
    }
}
