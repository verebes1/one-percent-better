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
   
   func notificationPrompt(n: Int, adjective: String) -> String {
      return """
            Task: Generate \(n) different examples of a \(adjective) notification to encourage someone to do their habit named "\(name.lowercased())".
            Requirements: For each notification, use between 10 and 60 characters. Return them as a JSON array named "notifications".
            """
   }
   
   func addNotification(_ notification: Notification) {
      self.addToNotifications(notification)
      Task {
         await NotificationManager.shared.setupNotification(notification: notification)
      }
   }
   
   func addNotifications(_ notifications: [Notification]) {
//      removeAllNotifications(notifs: notifications)
      for notif in notifications {
         addNotification(notif)
      }
   }
}
