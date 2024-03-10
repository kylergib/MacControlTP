//
//  MacControlTPApp.swift
//  MacControlTP
//
//  Created by kyle on 3/9/24.
//

import SwiftUI
import TPSwiftSDK

@main
struct MacControlTPApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var tp: TP?
    func applicationDidFinishLaunching(_ notification: Notification) {
        tp = TP()
        
        #if ENTRY
        let path = "~/KamiCloud/Documents/Swift/MacControlTP/build/MacControl"
        let expandedPath = NSString(string: path).expandingTildeInPath
        let url = URL(fileURLWithPath: expandedPath)
        tp?.client.plugin?.buildEntry(folderURL: url, fileName: "entry.tp")
        NSApplication.shared.terminate(nil)
        #else
        // runs if not in entry target
        DispatchQueue.global(qos: .background).async {
            self.tp?.client.start()
            
        }
        #endif
//        let allDevices = getAllDevices()
//
//        allDevices.forEach { id in
//            let deviceName = getDeviceName(id: id)
//            let deviceUID = getDeviceUID(id: id)
//            let transportType = getTransportType(id: id)
//            let hasVolume = hasVolume(id: id)
//            var volume: Float32 = -1
//            if (hasVolume) { volume = getVolume(id: id) }
//            if (deviceName == nil || deviceUID == nil) { return }
//            print("\(deviceName!) - \(deviceUID!) - \(transportType) - \(hasVolume) - \(volume)")
//
//            if deviceName == "Kyle’s AirPods Max" as CFString && hasVolume {
//                let result = setVolume(id: id, volume: 0.4)
//                print(result)
//            }
//
//        }
//        let id = AudioDevice.getDefaultOutput()
//        if id == 0 {
//            return
//        }
//        let deviceName = AudioDevice.getDeviceName(id: id)
//        let deviceUID = AudioDevice.getDeviceUID(id: id)
//        let transportType = AudioDevice.getTransportType(id: id)
//        let hasVolume = AudioDevice.hasVolume(id: id)
//        var volume: Float32 = -1
//        if hasVolume { volume = AudioDevice.getVolume(id: id) }
//        if deviceName == nil || deviceUID == nil { return }
//        print("\(deviceName!) - \(deviceUID!) - \(transportType) - \(hasVolume) - \(volume)")

        

        // Optionally, setup your daemon to perform tasks
    }
    

    func applicationWillTerminate(_ aNotification: Notification) {
        // Perform any cleanup before the application quits
        print("cleanup")
    }

    func test() {
        let client = TPClient()
        let plugin = Plugin(api: .v7, version: 100, name: "Swift Test", pluginId: "com.swift")
        plugin.pluginStartCommand = "executable.exe -param"
        plugin.pluginStartCmdMac = "executable.app -param"
        plugin.pluginStartCmdLinux = "executable.sh -param"
        plugin.pluginStartCmdWindows = "executable.exe -param"

        plugin.configuration = Configuration(parentCategory: ParentCategory.misc)

        let mainCategory = Category(id: "main", name: "Swift main", imagePath: "%TP_PLUGIN_FOLDER%ExamplePlugin/images/tools.png")
        let subCategory = Category(id: "second", name: "Swift 2nd", imagePath: "%TP_PLUGIN_FOLDER%ExamplePlugin/images/nottools.png")

        plugin.addCategory(category: mainCategory)
        plugin.addCategory(category: subCategory)

        let action1 = Action(id: "action1", name: "Action 1", type: ActionType.communicate, category: mainCategory)

        action1.onAction = { response in
            //            print(response.data)
            print("action 1")
            let dataList = response.data as? [Response]
            dataList?.forEach { data in
                print(data.id)
                print(data.value)
            }
        }

        action1.addData(data: ActionData(id: "actiondata001", type: ActionDataType.text("any text")))
        action1.addActionLine(actionLine: ActionLine(data: ["This actions shows multiple lines;", "Do something with value {$actiondata001$}"]))
        plugin.addAction(action: action1)
        /////////
        let action2 = Action(id: "action2", name: "Action 2", type: ActionType.communicate, category: subCategory)

        action2.onAction = { response in
            //            print(response.data)
            print("action 2")
            let dataList = response.data as? [Response]
            dataList?.forEach { data in
                print(data.id)
                print(data.value)
            }
        }

        action2.addData(data: ActionData(id: "first", type: ActionDataType.number(200), minValue: 100, maxValue: 350))
        plugin.addAction(action: action2)
        /////////
        let action3 = Action(id: "action3", name: "Action 3", type: ActionType.communicate, category: mainCategory)

        action3.onAction = { response in
            //            print(response.data)
            print("action 3")
            let dataList = response.data as? [Response]
            dataList?.forEach { data in
                print(data.id)
                print(data.value)
            }
        }

        action3.addActionLine(actionLine: ActionLine(data: ["This 3 shows multiple lines;", "Do something with value {$second$} and {$second2$}"]))
        action3.addData(data: ActionData(id: "second", type: ActionDataType.choice("200"), valueChoices: ["200", "400", "600", "800"]))
        action3.addData(data: ActionData(id: "second2", type: ActionDataType.choice("400"), valueChoices: ["200", "400", "600", "800"]))
        plugin.addAction(action: action3)
        /////////
        let action4 = Action(id: "action4", name: "Action 4", type: ActionType.communicate, category: mainCategory)

        action4.onAction = { response in
            print("action 4")
            //            print(response.data)
            let dataList = response.data as? [ResponseData]
            dataList?.forEach { data in
                print(data.id)
                print(data.value)
            }
        }

        action4.addData(data: ActionData(id: "actiondata003", type: ActionDataType.bool(true)))

        plugin.addAction(action: action4)

        let event1 = Event(id: "testEvent1", name: "Event 1", format: "When we eat $val as breakfast", category: mainCategory, valueType: EventValueType.choice, valueStateId: "fruit", valueChoices: ["Apple", "Pears", "Grapes"])

        plugin.addEvent(event: event1)

        let connectorData = ConnectorData(id: "connectLabel", dataType: ConnectorDataType.number)
//        let connector1 = Connector(id: "connect1", name: "1st Connector", format: "connectLabel", category: subCategory, data: connectorData)
//        plugin.addConnector(connector: connector1)
        let state1 = State(id: "state1", type: StateType.text, description: "1st state i have", category: mainCategory, defaultValue: "test")
        let state2 = State(id: "fruit", type: StateType.choice, description: "2nd state i have", category: subCategory, defaultValue: "Apple", valueChoices: ["Apple", "Pears", "Grapes"])

        plugin.addState(state: state1)
        plugin.addState(state: state2)
        //        plugin.addSetting(setting: Setting(name: "test setting", type: SettingType.number))

        let setting = Setting(name: "test setting", type: SettingType.number, toolTip: ToolTip(body: "body test"))
        plugin.addSetting(setting: setting)

        let setting2 = Setting(name: "test setting2", type: SettingType.text, toolTip: ToolTip(body: "body test2"))
        plugin.addSetting(setting: setting2)
        // left off after state
        client.plugin = plugin
        client.onSettingsChange = { settingsList in
            settingsList.forEach { setting in
                print("settings change: \(setting.name) - \(setting.value)")
            }
        }

        client.onInfo = { info in
            print(info.sdkVersion)
            print(info.tpVersionString)
            print(info.tpVersionCode)
            print(info.pluginVersion)
            print(info.status)
        }
        #if ENTRY
//        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("entry.tp")
        let path = "~/KamiCloud/Documents/Swift/MacControlTP/build"
        let expandedPath = NSString(string: path).expandingTildeInPath
        let url = URL(fileURLWithPath: expandedPath)
//        print(url.relativePath)
//        print(url.relativeString)
        client.plugin?.buildEntry(folderURL: url, fileName: "entry.tp")
        #else
        // runs if not in entry target
        client.start()
        #endif
    }
}
