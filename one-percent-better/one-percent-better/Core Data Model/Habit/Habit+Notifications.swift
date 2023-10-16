//
//  Habit+Notifications.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 3/3/23.
//

import Foundation
import UIKit
import CoreData

extension Habit {
    func addNotification(_ notification: Notification) {
        self.addToNotifications(notification)
        notificationManager.rebalanceHabitNotifications()
    }
    
    func addNotifications(_ notifications: [Notification]) {
        for notif in notifications {
            self.addToNotifications(notif)
        }
        if !notifications.isEmpty {
            notificationManager.rebalanceHabitNotifications()
        }
    }
}
