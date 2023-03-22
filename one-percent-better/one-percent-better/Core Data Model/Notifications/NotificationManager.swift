//
//  NotificationManager.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 3/16/23.
//

import Foundation
import UIKit
import CoreData

class NotificationManager {
   
   static var shared = NotificationManager()
   
   var moc: NSManagedObjectContext = CoreDataManager.shared.mainContext
   
   // TODO: 1.0.9 set this to 64
   static let MAX_NOTIFS = 25
   
   func setupNotification(notification: Notification) async {
      await rebalanceCurrentNotifications()
   }
   
   func requestNotifPermission() {
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
         if success {
            print("Notification permission granted!")
         } else if let error = error {
            print(error.localizedDescription)
         }
      }
   }
   
   struct PendingNotification: Comparable {
      let notifIDString: String
      let id: String
      let num: Int
      let date: Date
      let message: String
      
      static func < (lhs: PendingNotification, rhs: PendingNotification) -> Bool {
         lhs.date < rhs.date
      }
   }
   
   func pendingNotifications() async -> [PendingNotification] {
      let pendingNotificationRequests = await UNUserNotificationCenter.current().pendingNotificationRequests()
      
      // Step 3: Sort pending notifications by date scheduled
      var pendingNotifications: [PendingNotification] = []
      for notif in pendingNotificationRequests {
         guard let calTrigger = notif.trigger as? UNCalendarNotificationTrigger else {
            assert(false)
            continue
         }
         
         let dateComponents = calTrigger.dateComponents
         guard dateComponents.day != nil,
               dateComponents.month != nil,
               dateComponents.year != nil,
               dateComponents.hour != nil,
               dateComponents.minute != nil else {
            assert(false)
            continue
         }
         
         guard let date = Cal.date(from: dateComponents) else {
            assert(false)
            continue
         }
         
         let idComponents = notif.identifier.components(separatedBy: "&")
         
         guard idComponents.count == 3 else {
            assert(false)
            continue
         }
         
         let id = idComponents[1]
         guard let num = Int(idComponents[2]) else {
            assert(false)
            continue
         }
         let body = notif.content.body
         let pendingNotification = PendingNotification(notifIDString: notif.identifier, id: id, num: num, date: date, message: body)
         pendingNotifications.append(pendingNotification)
      }
      pendingNotifications = pendingNotifications.sorted()
      
      assert(pendingNotificationRequests.count == pendingNotifications.count, "Pending notifications doesn't match calendar triggered notifications")
      return pendingNotifications
   }
   
   func addNewNotification(notification: Notification, index: Int, date: DateComponents) async {
      let id = notification.id.uuidString
      let identifier = "OnePercentBetter&\(id)&\(index)"
      
      let dateObject = Cal.date(from: date)!
      let message = await notification.createScheduledNotification(index: index, on: dateObject)
      
      print("GENERATING NOTIFICATION \(index) for habit \(notification.habit.name), on date: \(date), id: \(id), with message: \(message)")
      
      let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
      let notifContent = notification.generateNotificationContent(message: message)
      let request = UNNotificationRequest(identifier: identifier, content: notifContent, trigger: trigger)
      do {
         try await UNUserNotificationCenter.current().add(request)
      } catch {
         print("ERROR GENERATING NOTIFICATION: \(error.localizedDescription)")
      }
   }
   
   func cleanUpScheduledNotifications() {
      let habits = Habit.habits(from: moc)
      let today = Date()
      for habit in habits {
         for notif in habit.notificationsArray {
            for scheduledNotification in notif.scheduledNotificationsArray {
               if scheduledNotification.date < today {
                  notif.removeFromScheduledNotifications(scheduledNotification)
                  moc.delete(scheduledNotification)
               }
            }
         }
      }
   }
   
   func removeNotification(_ notification: PendingNotification) {
      // TODO: JJJJ make this more efficient in 1.0.9
      let habits = Habit.habits(from: moc)
      for habit in habits {
         for notif in habit.notificationsArray {
            if notif.id.uuidString == notification.id {
               
               notif.unscheduledNotificationStrings.append(notification.message)
               
               for scheduledNotification in notif.scheduledNotificationsArray {
                  if scheduledNotification.index == notification.num {
                     notif.removeFromScheduledNotifications(scheduledNotification)
                     moc.delete(scheduledNotification)
                     return
                  }
               }
            }
         }
      }
   }
   
   func notificationTime(for notification: Notification) -> DateComponents {
      if let specificTime = notification as? SpecificTimeNotification {
         let time = Cal.dateComponents([.hour, .minute], from: specificTime.time)
         return time
      } else if let randomTime = notification as? RandomTimeNotification {
         let time = randomTime.getRandomTime()
         return time
      }
      fatalError("Unable to get time for notification")
   }
   
   func removeAllNotifications(notifs: [Notification]) {
      for notif in notifs {
         let id = notif.id
         for i in 0 ..< Self.MAX_NOTIFS {
            let notifID = "OnePercentBetter&\(id)&\(i)"
            print("Removing notification \(notifID)")
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notifID])
         }
         notif.reset()
      }
      
      // Rebalance
      Task { await rebalanceCurrentNotifications() }
   }
   
   func resetNotification(_ notification: Notification) {
      let id = notification.id
      for i in 0 ..< Self.MAX_NOTIFS {
         let notifID = "OnePercentBetter&\(id)&\(i)"
         print("Removing notification \(notifID)")
         UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notifID])
      }
      notification.reset()
   }
   
   
   func rebalanceCurrentNotifications() async {
      
      print("REBALANCING HABIT NOTIFICAITIONS!!!!")
      
      var pendingNotifications = await pendingNotifications()

      var notificationAllowance = Self.MAX_NOTIFS - pendingNotifications.count

      // Step 3: Keep adding new notifications until new scheduled date > latest pending notification request, or
      // maximum number of notification requests is reached
      for _ in 0 ..< Self.MAX_NOTIFS {
         guard let (notification, day, index) = getNextNotification() else {
            return
         }
         let nextIndex = (index + 1) % Self.MAX_NOTIFS
         print("nextIndex: \(nextIndex)")
         var dayAndTime = notificationTime(for: notification)
         let dayComponents = Cal.dateComponents([.day, .month, .year,], from: day)
         dayAndTime.calendar = Cal
         dayAndTime.day = dayComponents.day
         dayAndTime.month = dayComponents.month
         dayAndTime.year = dayComponents.year
         let newDate = Cal.date(from: dayAndTime)!
         
         guard let lastPendingNotif = pendingNotifications.last else {
            // No pending notification requests, add new notification
            await addNewNotification(notification: notification, index: nextIndex, date: dayAndTime)
            notificationAllowance -= 1
            continue
         }
         
         if newDate < lastPendingNotif.date && notificationAllowance <= 0 {
            pendingNotifications.removeLast()
            // Add notification message back in unscheduledNotifications list for that notif id
//            addMessageBackToNotification(message: lastPendingNotif.message, id: lastPendingNotif.id)
            removeNotification(lastPendingNotif)
            
            // Remove the scheduled notification
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [lastPendingNotif.notifIDString])
            
            // Add new notification
            await addNewNotification(notification: notification, index: nextIndex, date: dayAndTime)
            notificationAllowance -= 1
         } else {
            if notificationAllowance > 0 {
               await addNewNotification(notification: notification, index: nextIndex, date: dayAndTime)
               notificationAllowance -= 1
            } else {
               // Can't schedule any more notifications
               break
            }
         }
      }
      
      cleanUpScheduledNotifications()
      
      moc.fatalSave()
   }
   
   func getNextNotification() -> (notification: Notification, date: Date, index: Int)? {
      let habits = Habit.habits(from: moc)

      var nextNotifsAndDates: [(Notification, Date)] = []
      
      for habit in habits {
         for notif in habit.notificationsArray {
            let nextDate = notif.nextDue()
            nextNotifsAndDates.append((notif, nextDate))
         }
      }
      
      nextNotifsAndDates = nextNotifsAndDates.sorted { $0.1 < $1.1 }
      
      if let hasNext = nextNotifsAndDates.first {
         let lastScheduledIndex = hasNext.0.scheduledNotificationsArray.last?.index ?? -1
//         print("")
         print("Next to-be scheduled notification: \(hasNext.0.habit.name), date: \(hasNext.1), index: \(lastScheduledIndex)")
         return (hasNext.0, hasNext.1, lastScheduledIndex)
      } else {
         return nil
      }
   }
}
