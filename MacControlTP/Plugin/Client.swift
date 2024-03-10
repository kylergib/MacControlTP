//
//  Main.swift
//  MacControlTP
//
//  Created by kyle on 3/9/24.
//

import AppKit
import Foundation
import TPSwiftSDK

class TP {
    
    var client: TPClient
    var plugin: Plugin
    init() {
        client = TPClient()
        plugin = Plugin(api: .v7, version: 001, name: "Mac Control", pluginId: "com.maccontrol")
        plugin.pluginStartCmdMac = "open %TP_PLUGIN_FOLDER%MacControl/MacControlTP.app" // TODO: change later
        plugin.configuration = Configuration(parentCategory: ParentCategory.misc)

        defineCategories()
        Actions.createActions(plugin: plugin)
        print(plugin.connectors)
        Connectors.createConnectors(plugin: plugin)
        
        print(plugin.connectors)
        client.plugin = plugin
        print(plugin.connectors)
        setupOnInfo()
        setupOnClose()
        onConnection()
    }

    func setupOnInfo() {
        client.onInfo = { info in
            print(info.sdkVersion)
            print(info.tpVersionString)
            print(info.tpVersionCode)
            print(info.pluginVersion)
            print(info.status)
//            self.startMonitoringDefaultOutputVolume()
            AudioDevice.setupListener()
            Connector.updateConnectorData(connectorId: "defaultOutputVolumeConnector", value: 100)
//            Action.updateActionList(actionDataId: "testdata", value: ["dfas34","sadf","12"], actionId: "testid")
//            Notifications.myNoti(plugin: self.plugin)
        }
    }

    func setupOnClose() {
        client.onCloseRequest = {
            print("on close has been requested")
            DispatchQueue.main.async {
                NSApplication.shared.terminate(nil)
            }
        }
    }
    func onConnection() {
        client.onConnection = { isConnected in
                print(isConnected ? "connected" : "not connected")
            
        }
    }

    func defineCategories() {
        let volumeCategory = Category(id: "volume", name: "Volume", imagePath: "")
        plugin.addCategory(category: volumeCategory)
    }

    func startMonitoringDefaultOutputVolume() {
//        print("startin  g 1")
        DispatchQueue.global(qos: .background).async {
//            print("Starting 2")
            
            // Create a timer in a background thread
            let timer = Timer(timeInterval: 1.0, repeats: true) { _ in
//                print("Starting 3")
                let newVolume = AudioDevice.getVolume()
                if newVolume != AudioDevice.defaultDeviceOutputVolume {
                    AudioDevice.defaultDeviceOutputVolume = newVolume
                    // Assuming self.client.updateConnectorData is thread-safe;
                    // otherwise, consider dispatching it to an appropriate queue.
//                    print(Int(newVolume*100))
                    Connector.updateConnectorData(connectorId: "defaultOutputVolumeConnector", value: Int(newVolume*100))
                }
            }
            
            // Add the timer to the current RunLoop
            RunLoop.current.add(timer, forMode: .common)
            RunLoop.current.run() // Start the RunLoop
        }
    }
}
