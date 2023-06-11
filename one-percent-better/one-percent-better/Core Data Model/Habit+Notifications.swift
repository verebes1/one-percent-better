//
//  Habit+Notifications.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 3/3/23.
//

import Foundation
import UIKit

extension Habit {
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
   
   func removeNotifications(on date: Date) {
      var rebalance = false
      if NotificationManager.shared.rebalanceTask != nil {
         rebalance = true
         NotificationManager.shared.cancelRebalance()
      }
      
      for notification in notificationsArray {
         for scheduled in notification.scheduledNotificationsArray {
            if Cal.isDate(date, inSameDayAs: scheduled.date), scheduled.isScheduled {
               let identifier = "OnePercentBetter&\(scheduled.notification.id.uuidString)&\(scheduled.index)"
               print("remove notification with id: \(identifier)")
               UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
               scheduled.isScheduled = false
            }
         }
      }
      
      // Remove delivered notifications
      UNUserNotificationCenter.current().getDeliveredNotifications { notifs in
         for habitNotif in self.notificationsArray {
            for notif in notifs {
               if notif.request.identifier.hasPrefix("OnePercentBetter&\(habitNotif.id)") {
                  UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notif.request.identifier])
               }
            }
         }
      }
      
      if rebalance {
         NotificationManager.shared.rebalanceHabitNotifications()
      }
   }
   
   func addNotificationsBack(on date: Date) {
      var rebalance = false
      if NotificationManager.shared.rebalanceTask != nil {
         rebalance = true
         NotificationManager.shared.cancelRebalance()
      }
      
      for notification in notificationsArray {
         for scheduled in notification.scheduledNotificationsArray {
            if Cal.isDate(date, inSameDayAs: scheduled.date), !scheduled.isScheduled {
               let identifier = "OnePercentBetter&\(scheduled.notification.id.uuidString)&\(scheduled.index)"
               let dayComponents = Cal.dateComponents([.day, .month, .year, .hour, .minute], from: scheduled.date)
               let trigger = UNCalendarNotificationTrigger(dateMatching: dayComponents, repeats: false)
               let notifContent = notification.generateNotificationContent(message: scheduled.string)
               let request = UNNotificationRequest(identifier: identifier, content: notifContent, trigger: trigger)
               print("adding notification with id: \(identifier)")
               UNUserNotificationCenter.current().add(request) { error in
                  if let error = error {
                     print("error adding notification back: \(error.localizedDescription)")
                  }
               }
               scheduled.isScheduled = true
            }
         }
      }
      
      if rebalance {
         NotificationManager.shared.rebalanceHabitNotifications()
      }
   }
}
