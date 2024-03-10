//
//  Notifications.swift
//  MacControlTP
//
//  Created by kyle on 3/10/24.
//

import Foundation
import TPSwiftSDK

class Notifications {
    public static func myNoti(plugin: Plugin) {
        let notificationOption = NotifcationOption(id: "testno1234ti", title: "this is my title")
        let notification = TPNotification(id: "one1234", title: "second title", message: "update prolly", options: [notificationOption])
        notification.onNotificationClicked = { response in
            print(response.optionId)
        }
        plugin.addNotification(notification: notification)
        
    }
}
