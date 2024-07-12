//
//  Main.swift
//  MacControlTP
//
//  Created by kyle on 3/9/24.
//

import AppKit
import Foundation
import LoggerSwift
import TPSwiftSDK

class TP {
    private var logger = Logger(current: TP.self)
    var client: TPClient
    var plugin: Plugin

    init() {
        client = TPClient()

        plugin = Plugin(api: .v7, version: 100, name: "Mac Control", pluginId: "com.maccontrol")
        plugin.pluginStartCmdMac = "sh %TP_PLUGIN_FOLDER%MacControl/start_maccontroltp.sh"
        plugin.configuration = Configuration(parentCategory: ParentCategory.misc)

        defineCategories()
        Actions.createActions(plugin: plugin)
        Connectors.createConnectors(plugin: plugin)
        States.addStates(plugin: plugin)

        client.plugin = plugin
        setupOnInfo()
        setupOnClose()
        onConnection()
        client.onTimeout = {
            DispatchQueue.main.async {
                NSApplication.shared.terminate(nil)
            }
        }
    }

    func setupOnInfo() {
        client.onInfo = { _ in

            self.createDevices()
            AudioDevice.getDefaultOutputInit()
            AudioDevice.getDefaultInputInit()
            AudioDevice.setupOutputDeviceChangeListener(isOutput: true)
            AudioDevice.setupOutputDeviceChangeListener(isOutput: false)
//            AudioDevice.setupListener()
//
        }
    }

    func createDevices() {
        var outputDeviceNames = [String]()
        var inputDeviceNames = [String]()
        let allDevices = AudioDevice.getAllDevices()
        allDevices.forEach { id in
            let device = AudioDevice.createDevice(id: id)

            if device != nil {
                let isOutput = AudioDevice.isOutput(id: id)
                if isOutput {
//                    print("\(device?.name) is output")
                    outputDeviceNames.append("\(device!.name)")
                    AudioDevice.outputDeviceNameToId["\(device!.name)"] = id
                }
                let isInput = AudioDevice.isInput(id: id)
                if isInput {
//                    print("\(device?.name) is input")
                    inputDeviceNames.append("\(device!.name)")
                    AudioDevice.inputDeviceNameToId["\(device!.name)"] = id
                }
            }
        }

        State.updateChoiceList(choiceListId: "outputDevices", value: outputDeviceNames)
        State.updateChoiceList(choiceListId: "inputDevices", value: inputDeviceNames)
    }

    func setupOnClose() {
        client.onCloseRequest = {
            self.logger.info("on close has been requested")
            DispatchQueue.main.async {
                NSApplication.shared.terminate(nil)
            }
        }
    }

    func onConnection() {
        client.onConnection = { isConnected in
            self.logger.info(isConnected ? "connected" : "not connected")
        }
    }

    func defineCategories() {
        let category = Category(id: "MacControl", name: "MacControl", imagePath: "")
        plugin.addCategory(category: category)
    }
}
