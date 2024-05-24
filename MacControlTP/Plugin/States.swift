//
//  States.swift
//  MacControlTP
//
//  Created by kyle on 3/11/24.
//

import Foundation
import TPSwiftSDK
import LoggerSwift

enum States {
    private static var logger = Logger(current: States.self)
    static func addStates(plugin: Plugin) {
        defaultOutputStates(plugin: plugin)
        defaultInputStates(plugin: plugin)
    }

    static func defaultOutputStates(plugin: Plugin) {
        if !plugin.categories.keys.contains("MacControl") {
            logger.error("Could not find MacControl category")
            return
        }
        let nameState = State(id: "defaultOutputNameState", type: StateType.text, description: "Name of default output", category: plugin.categories["MacControl"]!, defaultValue: "")

        plugin.addState(state: nameState)

        let volumeState = State(id: "defaultOutputVolumeState", type: StateType.text, description: "Volume of default output", category: plugin.categories["MacControl"]!, defaultValue: "0")

        plugin.addState(state: volumeState)
    }

    static func defaultInputStates(plugin: Plugin) {
        if !plugin.categories.keys.contains("MacControl") {
            logger.error("Could not find MacControl category")
            return
        }
        let nameState = State(id: "defaultInputNameState", type: StateType.text, description: "Name of default input", category: plugin.categories["MacControl"]!, defaultValue: "")

        plugin.addState(state: nameState)

        let volumeState = State(id: "defaultInputVolumeState", type: StateType.text, description: "Volume of default input", category: plugin.categories["MacControl"]!, defaultValue: "0")

        plugin.addState(state: volumeState)
    }
}
