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
         fatalError("Should always be able to convert")
      }
      return arr
   }
   
   // TODO: 1.0.9 figure out this max
   var MAX_NOTIFS: Int {
      20
   }
   
   func notificationPrompt(n: Int, adjective: String) -> String {
      return """
            Task: Generate \(n) different examples of a \(adjective) notification to encourage someone to do their \(name.lowercased()) habit.
            Requirements: For each notification, use between 10 and 60 characters. Return them as a JSON array named "notifications".
            """
   }
   
   func addNotification(_ notification: Notification) {
      if let specificTime = notification as? SpecificTimeNotification,
         let date = specificTime.time,
         let id = specificTime.id {
         let time = Cal.dateComponents([.hour, .minute], from: date)
         addNotification(time: time, id: id)
      }
      
      if let randomTime = notification as? RandomTimeNotification,
         let date = randomTime.startTime,
         let id = randomTime.id {
         // TODO: 1.0.9 make this logic correct
         let time = Cal.dateComponents([.hour, .minute], from: date)
         addNotification(time: time, id: id)
      }
      self.addToNotifications(notification)
   }
   
   func randomTimes(between startDate: Date, and endDate: Date, n: Int) -> [DateComponents] {
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
      
      var times: [DateComponents] = []
      
      for _ in 0 ..< n {
         let randomTime = Int.random(in: startMinutes ..< endMinutes)
         let randomHour = randomTime / 60
         let randomMinute = randomTime % 60
         
         var components = DateComponents()
         components.hour = randomHour
         components.minute = randomMinute
         times.append(components)
      }
      return times
   }
   
   func addNotifications(_ notifications: [Notification]) {
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
   
   func addNotification(time: DateComponents, id: UUID) {
      Task {
         let notifications = await generateNotifications(n: 20)
         setupNotifications(from: Date(), index: 0, id: id, time: time, notifications: notifications)
      }
   }
   
   func generateNotifications(n: Int) async -> [UNMutableNotificationContent] {
      var notifs: [UNMutableNotificationContent] = []
      
      let messages = await getAINotifications(n)
      
      for i in 0 ..< messages.count {
         let content = UNMutableNotificationContent()
         content.title = self.name
         content.body = messages[i]
         content.sound = UNNotificationSound.default
         notifs.append(content)
      }
      return notifs
   }
   
   func getAINotifications(_ n: Int, level: Int = 0) async -> [String] {
      var notifs: [String] = []
      let adjectiveArray = ["creative", "funny", "motivating", "inspiring", "Gen Z"]
      for i in 0 ..< adjectiveArray.count {
         let count = n / adjectiveArray.count
         let someNotifs = await getAINotifications(count, adjective: adjectiveArray[i])
         notifs.append(contentsOf: someNotifs)
         print("notifs: \(notifs)")
      }
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
            
            print("--------- \(adjective) ------------")
            
//            answer = answer.replacingOccurrences(of: "\n", with: "")
//            answer = answer.replacingOccurrences(of: "\"", with: "")
//            answer = answer.replacingOccurrences(of: "\'", with: "'")
            print("ChatGPT answer: \(answer)")
            
            
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
      }
      return list
   }
   
   /// Set up the next N notifications, where N = messages.count
   /// - Parameters:
   ///   - date: The start date (including this day)
   ///   - time: What time to send the notification
   ///   - messages: The next N notification messages to use
   ///
   func setupNotifications(from date: Date, index: Int, id: UUID, time: DateComponents, notifications: [UNMutableNotificationContent]) {
      
      for i in 0 ..< notifications.count {
         print("i: \(i), index: \(index), i + index: \(i + index)")
         if (i + index) >= MAX_NOTIFS {
            break
         }
         let day = Cal.add(days: i, to: date)
         let dayComponents = Cal.dateComponents([.day, .month, .year,], from: day)
         var dayAndTime = time
         dayAndTime.day = dayComponents.day
         dayAndTime.month = dayComponents.month
         dayAndTime.year = dayComponents.year
         let trigger = UNCalendarNotificationTrigger(dateMatching: dayAndTime, repeats: false)
         
         let offset = index + i
         let identifier = "OnePercentBetter-\(id)-\(offset)"
         print("GENERATING NOTIFICATION \(offset) for habit \(name), on date: \(dayAndTime), id: \(identifier), and time: \(time), with message: \(notifications[i].body)")
         let request = UNNotificationRequest(identifier: identifier, content: notifications[i], trigger: trigger)
         UNUserNotificationCenter.current().add(request)
      }
   }
   
   func removeAllNotifications(notifs: [Notification]) {
      for notif in notifs {
         guard let id = notif.id else { continue }
         for i in 0 ..< MAX_NOTIFS {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["OnePercentBetter-\(id)-\(i)"])
         }
      }
   }
}
