//
//  Connectors.swift
//  MacControlTP
//
//  Created by kyle on 3/10/24.
//

import Foundation
import TPSwiftSDK
import LoggerSwift

enum Connectors {
    private static var logger = Logger(current: Connectors.self)
    static func createConnectors(plugin: Plugin) {
        defaultOutputVolumeConnector(plugin: plugin)
        defaultInputVolumeConnector(plugin: plugin)
    }

    static func defaultOutputVolumeConnector(plugin: Plugin) {
        if !plugin.categories.keys.contains("MacControl") {
            logger.error("Could not find MacControl category")
            return
        }
        let connector = Connector(id: "defaultOutputVolumeConnector", name: "Default Output Connector", format: "defaultOutputVolumeConnectorLabel", category: plugin.categories["MacControl"]!, dataList: [])
        connector.onConnectorChange = { response in
            DispatchQueue.global(qos: .background).async {
                if response.value == nil { return }
                let floatValue = Float(response.value as! Int)/100.00
                let id = AudioDevice.defaultInput != nil ? AudioDevice.defaultOutput!.id : AudioDevice.getDefaultOutput()
                _ = AudioDevice.setVolume(id: id, volume: floatValue)
            }
        }
        plugin.addConnector(connector: connector)
    }

    static func defaultInputVolumeConnector(plugin: Plugin) {
        if !plugin.categories.keys.contains("MacControl") {
            logger.error("Could not find MacControl category")
            return
        }
        let connector = Connector(id: "defaultInputVolumeConnector", name: "Default Input Connector", format: "defaultInputVolumeConnectorLabel", category: plugin.categories["MacControl"]!, dataList: [])
        connector.onConnectorChange = { response in
            DispatchQueue.global(qos: .background).async {
                if response.value == nil { return }
                let floatValue = Float(response.value as! Int)/100.00

                let id = AudioDevice.defaultInput != nil ? AudioDevice.defaultInput!.id : AudioDevice.getDefaultInput()
                _ = AudioDevice.setVolume(id: id, volume: floatValue, isOutput: false)
            }
        }
        plugin.addConnector(connector: connector)
    }
}
