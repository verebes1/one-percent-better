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
   static let MAX_NOTIFS = 60
   
   lazy var queue = DispatchQueue(label: "NotificationManager", qos: .userInitiated)
   
   var permissionGranted = false

   func requestNotificationPermission() async -> Bool? {
      do {
         permissionGranted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
         return permissionGranted
      } catch {
         print("Error getting notification permission")
         return nil
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
      
      return pendingNotifications
   }
   
   func cleanUpScheduledNotifications() throws {
      let today = Date()
      var nextNotifDate: Date?
      if let (_, date, _) = try getNextNotification() {
         nextNotifDate = date
      }
      let scheduledNotifications = moc.fetchArray(ScheduledNotification.self)
      
      for scheduledNotification in scheduledNotifications {
         if scheduledNotification.date < today {
            scheduledNotification.notification.removeFromScheduledNotifications(scheduledNotification)
         } else if let nextDate = nextNotifDate,
            scheduledNotification.date >= nextDate {
            scheduledNotification.notification.removeFromScheduledNotifications(scheduledNotification)
         }
      }
   }
   
   func removeNotification(_ notification: PendingNotification) {
      var notifications: [Notification]
      do {
         let fetchRequest: NSFetchRequest<Notification> = Notification.fetchRequest()
         fetchRequest.predicate = NSPredicate(format: "id == %@", notification.id)
         notifications = try moc.fetch(fetchRequest)
      } catch {
         assertionFailure("Unable to find notification in Core Database")
         return
      }
      
      for notif in notifications {
         guard let scheduledNotif = notif.scheduledNotificationsArray.first(where: { $0.index == notification.num }) else {
            continue
         }
         
         notif.unscheduledNotificationStrings.append(notification.message)
         notif.removeFromScheduledNotifications(scheduledNotif)
         moc.delete(scheduledNotif)
         return
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
   
   // MARK: Rebalance
   
   let semaphore = DispatchSemaphore(value: 0)
   var rebalanceTask: Task<Void, Never>?
   var shouldRestartRebalance = false
   
   func rebalanceHabitNotifications() {
      if let rt = rebalanceTask {
         rt.cancel()
         Task {
            try? await Task.sleep(for: Duration.seconds(1))
            print("~W~ waiting for cancellation to restart new rebalance ~W~")
            rebalanceHabitNotifications()
         }
      } else {
         print("~+~ Starting new rebalance task ~+~")
         rebalanceTask = Task {
            do {
               try await rebalanceHabitNotificationsTask()
            } catch {
               print("~-~ startRebalanceTask task was cancelled! ~-~")
            }
            rebalanceTask = nil
         }
      }
   }
   
   func cancelRebalance() {
      rebalanceTask?.cancel()
   }
   
   func rebalanceHabitNotificationsTask() async throws {
      
      print("~~~ Rebalancing habit notifications! ~~~")
      
      // Step 1: Get pending notifications
      var pendingNotifications = await pendingNotifications()
      var notificationAllowance = Self.MAX_NOTIFS - pendingNotifications.count

      // Step 2: Keep adding new notifications until new scheduled date > latest pending notification request, or
      // maximum number of notification requests is reached
      for _ in 0 ..< Self.MAX_NOTIFS {
         try Task.checkCancellation()
         
         guard let (notification, day, index) = try getNextNotification() else {
            break
         }
         let nextIndex = (index + 1) % Self.MAX_NOTIFS
         try Task.checkCancellation()
         var dayAndTime = notificationTime(for: notification)
         let dayComponents = Cal.dateComponents([.day, .month, .year,], from: day)
         dayAndTime.calendar = Cal
         dayAndTime.day = dayComponents.day
         dayAndTime.month = dayComponents.month
         dayAndTime.year = dayComponents.year
         let newDate = Cal.date(from: dayAndTime)!
         
         guard let lastPendingNotif = pendingNotifications.last else {
            // No pending notification requests, add new notification
            try await notification.addNotificationRequest(index: nextIndex, date: dayAndTime)
            notificationAllowance -= 1
            continue
         }
         
         if newDate < lastPendingNotif.date && notificationAllowance <= 0 {
            pendingNotifications.removeLast()
            // Add notification message back in unscheduledNotifications list for that notif id
            removeNotification(lastPendingNotif)
            
            // Remove the scheduled notification
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [lastPendingNotif.notifIDString])
            
            // Add new notification
            try await notification.addNotificationRequest(index: nextIndex, date: dayAndTime)
            notificationAllowance -= 1
         } else {
            if notificationAllowance > 0 {
               try await notification.addNotificationRequest(index: nextIndex, date: dayAndTime)
               notificationAllowance -= 1
            } else {
               // Can't schedule any more notifications
               break
            }
         }
      }
      
      // Step 3: Remove any already sent notifications from scheduled list
      try cleanUpScheduledNotifications()
      
      await moc.perform {
         self.moc.assertSave()
      }
      
      print("~o~ Finished rebalancing habit notifications! ~o~")
   }
   
   func getNextNotification() throws -> (notification: Notification, date: Date, index: Int)? {
      let habits = Habit.habits(from: moc)
      var nextNotifsAndDates: [(Notification, Date)] = []
      
      for habit in habits {
         for notif in habit.notificationsArray {
            let nextDate = notif.nextDue()
            nextNotifsAndDates.append((notif, nextDate))
         }
         try Task.checkCancellation()
      }
      
      nextNotifsAndDates = nextNotifsAndDates.sorted { $0.1 < $1.1 }
      
      if let hasNext = nextNotifsAndDates.first {
         let lastScheduledIndex = hasNext.0.scheduledNotificationsArray.last?.index ?? -1
         print("Next to-be scheduled notification: \(hasNext.0.habit.name), date: \(hasNext.1), index: \(lastScheduledIndex)")
         return (hasNext.0, hasNext.1, lastScheduledIndex)
      } else {
         return nil
      }
   }
}
