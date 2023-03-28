//
//  Habit+Notifications.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 3/3/23.
//

import Foundation
import UIKit

extension Habit {
   
   var notificationsArray: [Notification] {
      guard let arr = notifications?.array as? [Notification] else {
         return []
      }
      return arr
   }
   
   func addNotification(_ notification: Notification) {
      self.addToNotifications(notification)
      NotificationManager.shared.rebalanceHabitNotifications()
   }
   
   func addNotifications(_ notifications: [Notification]) {
      for notif in notifications {
         self.addToNotifications(notif)
      }
      if !notifications.isEmpty {
         NotificationManager.shared.rebalanceHabitNotifications()
      }
   }
}
