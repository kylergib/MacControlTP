//
//  Connectors.swift
//  MacControlTP
//
//  Created by kyle on 3/10/24.
//

import Foundation
import TPSwiftSDK

enum Connectors {
    static func createConnectors(plugin: Plugin) {
        defaultOutputVolumeConnector(plugin: plugin)
    }

    static func defaultOutputVolumeConnector(plugin: Plugin) {
        let connector = Connector(id: "defaultOutputVolumeConnector", name: "Default Output Connector", format: "defaultOutputVolumeConnectorLabel", category: plugin.categories["volume"]!, dataList: [])
        connector.onConnectorChange = { response in
            DispatchQueue.global(qos: .background).async {
                if (response.value == nil) { return }
                let floatValue = Float(response.value as! Int)/100.00
                print(floatValue)
                _ = AudioDevice.setVolume(volume: floatValue)
            }
        }
        plugin.addConnector(connector: connector)
    }
}
