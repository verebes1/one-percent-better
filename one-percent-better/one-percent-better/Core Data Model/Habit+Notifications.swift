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
   
   // TODO: 1.0.9 set this to 64
   var MAX_NOTIFS: Int {
      25
   }
   
   func notificationPrompt(n: Int, adjective: String) -> String {
      return """
            Task: Generate \(n) different examples of a \(adjective) notification to encourage someone to do their \(name.lowercased()) habit.
            Requirements: For each notification, use between 10 and 60 characters. Return them as a JSON array named "notifications".
            """
   }
   
   func addNotification(_ notification: Notification) {
      self.addToNotifications(notification)
      Task {
         let notificationMessages = await getAINotifications(MAX_NOTIFS)
         await setupNotifications(notification: notification, notificationMessages: notificationMessages)
         
         UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("JJJJ notification requests pending: \(requests)")
         }
      }
   }
   
   func addNotifications(_ notifications: [Notification]) {
      removeAllNotifications(notifs: notifications)
      for notif in notifications {
         addNotification(notif)
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
   
   func generateNotificationContent(message: String) -> UNMutableNotificationContent {
      let content = UNMutableNotificationContent()
      content.title = self.name
      content.body = message
      content.sound = UNNotificationSound.default
      return content
   }
   
   func getAINotifications(_ n: Int, level: Int = 0) async -> [String] {
      var notifs: [String] = []
      let adjectiveArray = ["creative", "funny", "motivating", "inspiring", "funny Gen Z"]
      for i in 0 ..< adjectiveArray.count {
         let count = n / adjectiveArray.count
         let someNotifs = await getAINotifications(count, adjective: adjectiveArray[i])
         notifs.append(contentsOf: someNotifs)
      }
      print("notifs: \(notifs)")
      return notifs
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
   
   func getAINotifications(_ n: Int, adjective: String, level: Int = 0) async -> [String] {
      var list: [String] = []
      guard level <= 3 else { return list }
      print("Getting \(n) notifications from ChatGPT")
      do {
         if let answer = try await OpenAI.shared.chatModel(prompt: notificationPrompt(n: n, adjective: adjective)) {
            print("ChatGPT \(adjective) answer: \(answer)")
            
            
            guard let jsonList = parseGPTAnswer(answer: answer) else {
               print("ChatGPT answer failed to parse JSON trying again with level: \(level + 1)")
               return await getAINotifications(n, adjective: adjective, level: level + 1)
            }
            list = jsonList
            //            list = answer.components(separatedBy: ",")
            
            guard list.count >= n else {
               print("ChatGPT answer failed, COUNT = \(list.count) trying again with level: \(level + 1)")
               return await getAINotifications(n, adjective: adjective, level: level + 1)
            }
            
            list.removeLast(list.count - n)
            
            for i in 0 ..< list.count {
               list[i] = list[i].trimmingCharacters(in: .whitespaces)
            }
            
            list.removeAll { $0.isEmpty || $0 == "" }
            
            print("List: \(list)")
         }
      } catch {
         print("ERROR: \(error.localizedDescription)")
         return await getAINotifications(n, adjective: adjective, level: level + 1)
      }
      list.shuffle()
      return list
   }
   
   func pendingNotifications() async -> [UNNotificationRequest] {
      return await withCheckedContinuation { continuation in
         UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("JJJJ notification requests pending: \(requests)")
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
      
      // Step 4: Loop over list until new scheduled > last list element
      for i in 0 ..< MAX_NOTIFS {
         let day = Cal.add(days: i, to: Date())
         var dayAndTime = notificationTime(for: notification)
         let dayComponents = Cal.dateComponents([.day, .month, .year,], from: day)
         dayAndTime.calendar = Cal
         dayAndTime.day = dayComponents.day
         dayAndTime.month = dayComponents.month
         dayAndTime.year = dayComponents.year
         
         let newDate = Cal.date(from: dayAndTime)!
         if let lastPendingNotif = pendingNotifications.last {
            if newDate < lastPendingNotif.date {
               pendingNotifications.removeLast()
               // Add notification message back in unscheduledNotifications list for that notif id
               addMessageBackToNotification(message: lastPendingNotif.message, id: lastPendingNotif.id)
               
               // Remove the scheduled notification
               UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [lastPendingNotif.notifIDString])
               
               // Add new notification
               addNewNotification(index: i, id: notification.id.uuidString, date: dayAndTime, message: notificationMessages[i])
            } else {
               break
            }
         } else {
            // Add new notification
            addNewNotification(index: i, id: notification.id.uuidString, date: dayAndTime, message: notificationMessages[i])
         }
      }
   }
   
   func addNewNotification(index: Int, id: String, date: DateComponents, message: String) {
      let identifier = "OnePercentBetter&\(id)&\(index)"
      print("GENERATING NOTIFICATION \(index) for habit \(name), on date: \(date), id: \(id), with message: \(message)")
      let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
      let notifContent = generateNotificationContent(message: message)
      let request = UNNotificationRequest(identifier: identifier, content: notifContent, trigger: trigger)
      UNUserNotificationCenter.current().add(request) { error in
         if error != nil {
            print("ERROR GENERATING NOTIFICATION")
         }
      }
   }
   
   func addMessageBackToNotification(message: String, id: String) {
      // TODO: 1.0.9 Use Core data fetch to get this more efficiently
      let habits = Habit.habits(from: moc)
      for habit in habits {
         for notif in habit.notificationsArray {
            if notif.id.uuidString == id {
               notif.unscheduledNotificationStrings.append(message)
               break
            }
         }
      }
   }
   
   func notificationTime(for notification: Notification) -> DateComponents {
      if let specificTime = notification as? SpecificTimeNotification {
         let time = Cal.dateComponents([.hour, .minute], from: specificTime.time)
         return time
      } else if let randomTime = notification as? RandomTimeNotification {
         let time = getRandomTime(between: randomTime.startTime, and: randomTime.endTime)
         return time
      }
      fatalError("Unable to get time for notification")
   }
   
   func getRandomTime(between startDate: Date, and endDate: Date) -> DateComponents {
      let startTime = Cal.dateComponents([.hour, .minute], from: startDate)
      let endTime = Cal.dateComponents([.hour, .minute], from: endDate)
      
      guard let startHour = startTime.hour,
            let startMinute = startTime.minute,
            let endHour = endTime.hour,
            let endMinute = endTime.minute else {
         fatalError("Unable to get hour and minutes for random notification")
      }
      
      let startMinutes = startHour * 60 + startMinute
      let endMinutes = endHour * 60 + endMinute
      
      guard startMinutes <= endMinutes else {
         fatalError("Bad random time notification start and end times")
      }
      let randomTime = Int.random(in: startMinutes ..< endMinutes)
      let randomHour = randomTime / 60
      let randomMinute = randomTime % 60
      
      var components = DateComponents()
      components.hour = randomHour
      components.minute = randomMinute
      return components
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
   }
}
