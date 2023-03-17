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
   var MAX_NOTIFS: Int {
      25
   }
   
   func setupNotification(notification: Notification) async {
      let notificationMessages = await getAINotifications(MAX_NOTIFS)
      await setupNotifications(notification: notification, notificationMessages: notificationMessages)
      
      UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
         print("JJJJ notification requests pending: \(requests)")
      }
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
   
   func getAINotifications(_ n: Int, level: Int = 0) async -> [String] {
//      var notifs: [String] = []
//      let adjectiveArray = ["creative", "funny", "motivating", "inspiring", "funny Gen Z"]
//      for i in 0 ..< adjectiveArray.count {
//         let count = n / adjectiveArray.count
//         let someNotifs = await getAINotifications(count, adjective: adjectiveArray[i])
//         notifs.append(contentsOf: someNotifs)
//      }
//      print("notifs: \(notifs)")
//      return notifs
      
      return ["Find paradise in the sun!", "Vitamin D boost awaits you.", "Beaming sun and endless fun!", "Sunny day ahead! Get outside.", "Tans fade, memories last.", "Time to turn up the heat and get your tan on!", "Don\'t be a vampire, embrace the sunshine!", "Vitamin D is your friend, go soak up some rays!", "You\'re looking a bit pale, get some sun!", "Your tan lines miss you, get outside!", "Enjoy the sunshine for a healthy dose of Vitamin D!", "Sunshine is free therapy, soak it up!", "A day spent in the sun is a day well spent!", "Get out and let the sun work its magic on you!", "Soak up the sun and let your worries melt away!", "Sunshine is a natural mood booster", "Soak up some vitamin D today", "Enjoy the warmth of the sun on your skin", "A sunny day awaits you, go outside!", "Take a break and catch some rays", "Vitamin D is a mood booster. Go out and catch some sun vibes!", "Let\'s get tan and sandy, hit the beach and forget your worries!", "Yo fam, it\'s lit outside, put on some shades & get some Vit D!", "The sun is a natural highlighter. Get that summer glow on fleek fam!", "Can\'t make gains laying on the couch. Get outside and catch some rays!"]
   }
   
   func parseGPTAnswer(answer: String) -> [String]? {
      do {
         if let jsonData = answer.data(using: .utf8) {
            if let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
               if let jsonArray = jsonDict["notifications"] as? [String] {
                  return jsonArray
               }
            } else if let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String] {
               return jsonArray
            }
         }
      } catch {
         print("Error parsing JSON: \(error)")
      }
      return nil
   }
   
//   func getAINotifications(_ n: Int, adjective: String, level: Int = 0) async -> [String] {
//      var list: [String] = []
//      guard level <= 3 else { return list }
//      print("Getting \(n) notifications from ChatGPT")
//      do {
//         if let answer = try await OpenAI.shared.chatModel(prompt: notificationPrompt(n: n, adjective: adjective)) {
//            print("ChatGPT \(adjective) answer: \(answer)")
//            
//            
//            guard let jsonList = parseGPTAnswer(answer: answer) else {
//               print("ChatGPT answer failed to parse JSON trying again with level: \(level + 1)")
//               return await getAINotifications(n, adjective: adjective, level: level + 1)
//            }
//            list = jsonList
//            //            list = answer.components(separatedBy: ",")
//            
//            guard list.count >= n else {
//               print("ChatGPT answer failed, COUNT = \(list.count) trying again with level: \(level + 1)")
//               return await getAINotifications(n, adjective: adjective, level: level + 1)
//            }
//            
//            list.removeLast(list.count - n)
//            
//            for i in 0 ..< list.count {
//               list[i] = list[i].trimmingCharacters(in: .whitespaces)
//            }
//            
//            list.removeAll { $0.isEmpty || $0 == "" }
//            
//            print("List: \(list)")
//         }
//      } catch {
//         print("ERROR: \(error.localizedDescription)")
//         return await getAINotifications(n, adjective: adjective, level: level + 1)
//      }
//      list.shuffle()
//      return list
//   }
   
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
   
   /// Set up the next N notifications, where N = messages.count
   /// - Parameters:
   ///   - date: The start date (including this day)
   ///   - time: What time to send the notification
   ///   - messages: The next N notification messages to use
   ///
   func setupNotifications(notification: Notification, notificationMessages: [String]) async {
      
      // Step 1: Store AI notification messages
      notification.unscheduledNotificationStrings = notificationMessages
      
      // Step 2: Get list of pending notifications
      var pendingNotifications = await pendingNotifications()
      
      var notificationAllowance = MAX_NOTIFS - pendingNotifications.count
      
      // Step 3: Keep adding new notifications until new scheduled date > latest pending notification request, or
      // maximum number of notification requests is reached
      let today = Date()
      for i in 0 ..< MAX_NOTIFS {
         let day = Cal.add(days: i, to: today)
         var dayAndTime = notificationTime(for: notification)
         let dayComponents = Cal.dateComponents([.day, .month, .year,], from: day)
         dayAndTime.calendar = Cal
         dayAndTime.day = dayComponents.day
         dayAndTime.month = dayComponents.month
         dayAndTime.year = dayComponents.year
         let newDate = Cal.date(from: dayAndTime)!
         
         guard let lastPendingNotif = pendingNotifications.last else {
            // No pending notification requests, add new notification
            await addNewNotification(notification: notification, index: i, date: dayAndTime)
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
            await addNewNotification(notification: notification, index: i, date: dayAndTime)
            notificationAllowance -= 1
         } else {
            if notificationAllowance > 0 {
               await addNewNotification(notification: notification, index: i, date: dayAndTime)
               notificationAllowance -= 1
            } else {
               // Can't schedule any more notifications
               break
            }
         }
      }
      cleanUpScheduledNotifications()
   }
   
   func addNewNotification(notification: Notification, index: Int, date: DateComponents) async {
      let id = notification.id.uuidString
      let identifier = "OnePercentBetter&\(id)&\(index)"
      // TODO: 1.0.9 what to do if unscheduledNotificationStrings is running low?
      assert(!notification.unscheduledNotificationStrings.isEmpty)
      if notification.unscheduledNotificationStrings.isEmpty {
         await notification.unscheduledNotificationStrings = getAINotifications(MAX_NOTIFS)
      }
      
      let dateObject = Cal.date(from: date)!
      let message = notification.createScheduledNotification(index: index, on: dateObject)
      
      print("GENERATING NOTIFICATION \(index) for habit \(notification.habit.name), on date: \(date), id: \(id), with message: \(message)")
      
      let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
      let notifContent = notification.generateNotificationContent(message: message)
      let request = UNNotificationRequest(identifier: identifier, content: notifContent, trigger: trigger)
      UNUserNotificationCenter.current().add(request) { error in
         if error != nil {
            print("ERROR GENERATING NOTIFICATION: \(error!.localizedDescription)")
         }
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
         for i in 0 ..< MAX_NOTIFS {
            let notifID = "OnePercentBetter&\(id)&\(i)"
            print("Removing notification \(notifID)")
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notifID])
         }
      }
      
      // Rebalance
      Task { await rebalanceCurrentNotifications() }
   }
   
   func rebalanceCurrentNotifications() async {
      var pendingNotifications = await pendingNotifications()

      var notificationAllowance = MAX_NOTIFS - pendingNotifications.count

      // Step 3: Keep adding new notifications until new scheduled date > latest pending notification request, or
      // maximum number of notification requests is reached
      for _ in 0 ..< notificationAllowance {
         guard let (notification, day, index) = getNextNotification() else {
            return
         }
         let nextIndex = index + 1 // TODO: ADD % MAX_NOTIFS
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
         let lastScheduledIndex = hasNext.0.scheduledNotificationsArray.last?.index ?? 0
         return (hasNext.0, hasNext.1, lastScheduledIndex)
      } else {
         return nil
      }
   }
}
