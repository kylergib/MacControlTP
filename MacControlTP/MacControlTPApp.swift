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
        let path = "~/KamiCloud/Documents/Swift/MacControlTP/"
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
    }
    

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }

    
}
