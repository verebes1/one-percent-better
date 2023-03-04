//
//  Habit+Notifications.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 3/3/23.
//

import Foundation
import UIKit

extension Habit {
   
   // TODO: 1.0.9 fix this
   var MAX_NOTIFS: Int {
      20
   }
   
   var NOTIF_PROMPT: String {
      "Using less than 50 characters, what is an example of a creative notification to encourage someone to do their \(name) habit?"
   }
   
   func addNotifications(notifications: [Notification]) {
      for notification in notifications {
         if let specificTime = notification as? SpecificTimeNotification {
            let time = Cal.dateComponents([.hour, .minute], from: specificTime.time)
            addNotification(time: time)
         }
         
         if let randomTime = notification as? RandomTimeNotification {
            // TODO: 1.0.9 make this logic correct
            let time = Cal.dateComponents([.hour, .minute], from: randomTime.fromTime)
            addNotification(time: time)
         }
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
   
   func addNotification(time: DateComponents) {
      let notifications = generateNotifications(n: 10)
      setupNotifications(from: Date(), index: 0, time: time, notifications: notifications)
   }
   
   func generateNotifications(n: Int) -> [UNMutableNotificationContent] {
      var notifs: [UNMutableNotificationContent] = []
      
      let messages = getChatGPTAnswers(n)
      
      for i in 0 ..< n {
         let content = UNMutableNotificationContent()
         content.title = "\(self.name) Reminder"
         content.subtitle = messages[i]
         content.sound = UNNotificationSound.default
         notifs.append(content)
      }
      return notifs
   }
   
   func getChatGPTAnswers(_ n: Int) async -> [String] {
      var answers: [String] = []
      for _ in 0 ..< n {
         do {
            if let notif = try await OpenAI.shared.completion(prompt: NOTIF_PROMPT) {
               answers.append(notif)
            }
         } catch {
            print("ERROR: \(error.localizedDescription)")
         }
      }
      return answers
   }
   
   
   
   /// Set up the next N notifications, where N = messages.count
   /// - Parameters:
   ///   - date: The start date (including this day)
   ///   - time: What time to send the notification
   ///   - messages: The next N notification messages to use
   ///
   func setupNotifications(from date: Date, index: Int, time: DateComponents, notifications: [UNMutableNotificationContent]) {
      
      for i in 0 ..< notifications.count {
         if (i + index) >= MAX_NOTIFS {
            break
         }
         let dayComponents = Cal.dateComponents([.day, .month, .year,], from: Cal.add(days: i, to: date))
         var dayAndTime = time
         dayAndTime.day = dayComponents.day
         dayAndTime.month = dayComponents.month
         dayAndTime.year = dayComponents.year
         let trigger = UNCalendarNotificationTrigger(dateMatching: dayAndTime, repeats: false)
         
         let offset = index + i
         let request = UNNotificationRequest(identifier: "OnePercentBetter-DailyReminder-\(offset)", content: notifications[i], trigger: trigger)
         UNUserNotificationCenter.current().add(request)
      }
   }
   
   func removeAllNotifications() {
      for i in 0 ..< MAX_NOTIFS {
         UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["OnePercentBetter-DailyReminder-\(i)"])
      }
   }
}
