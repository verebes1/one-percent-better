//
//  Notification.swift
//  
//
//  Created by Jeremy Cook on 3/5/23.
//
//

import Foundation
import CoreData
import UIKit

@objc(Notification)
public class Notification: NSManagedObject {
   @nonobjc public class func fetchRequest() -> NSFetchRequest<Notification> {
      return NSFetchRequest<Notification>(entityName: "Notification")
   }
   
   @NSManaged public var id: UUID
   
   @NSManaged public var habit: Habit
   
   /// An array of scheduled notifications, which contain an index, date, and string per scheduled notification
   @NSManaged public var scheduledNotifications: NSOrderedSet?
   
   var scheduledNotificationsArray: [ScheduledNotification] {
      return scheduledNotifications?.array as? [ScheduledNotification] ?? []
   }
   
   /// This array contains notification strings that can be used in the future, so that we don't need to call OpenAI every time.
   /// Instead, OpenAI is called in batches (for ex: give me 10 notifications), and the overflow notifications are stored here
   @NSManaged public var unscheduledNotificationStrings: [String]
   
   var moc: NSManagedObjectContext = CoreDataManager.shared.mainContext
   
   func createScheduledNotification(index: Int, on date: Date) async throws -> String {
      if unscheduledNotificationStrings.isEmpty {
         let messages = try await getAINotifications(NotificationManager.MAX_NOTIFS / 2)
         await moc.perform {
            self.unscheduledNotificationStrings = messages
         }
      }
      var message: String!
      await moc.perform {
         message = self.unscheduledNotificationStrings.removeLast()
         let scheduledNotification = ScheduledNotification(context: self.moc, index: index, date: date, string: message, notification: self)
         self.addToScheduledNotifications(scheduledNotification)
      }
      print("Adding to scheduled notification for id: \(self.id), index: \(index), date: \(date)")
      return message
   }
   
   func addNotificationRequest(index: Int, date: DateComponents) async throws {
      let identifier = "OnePercentBetter&\(id.uuidString)&\(index)"
      let dateObject = Cal.date(from: date)!
      let message = try await createScheduledNotification(index: index, on: dateObject)
      let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
      let notifContent = generateNotificationContent(message: message)
      let request = UNNotificationRequest(identifier: identifier, content: notifContent, trigger: trigger)
      do {
         try await UNUserNotificationCenter.current().add(request)
      } catch {
         print("Error generating notification request: \(error.localizedDescription)")
      }
   }
   
   func notificationPrompt(n: Int, adjective: String) -> String {
      return """
             Task: Generate \(n) different examples of a \(adjective) notification to encourage someone to do their habit named "\(habit.name.lowercased())".
             Requirements: For each notification, use between 10 and 60 characters. Return them as a JSON array named "notifications".
             """
   }
   
   func getAINotifications(_ n: Int) async throws -> [String] {
      var notifs: [String] = []
      let adjectiveArray = ["creative": 7, "motivating": 5, "inspiring": 5, "funny": 7, "funny Gen Z": 8]
      for (adjective, count) in adjectiveArray {
         if let someNotifs = try await getAINotifications(count, adjective: adjective) {
            notifs.append(contentsOf: someNotifs)
         }
      }
      if notifs.isEmpty {
         notifs = defaultNotifications()
      }
      return notifs
   }
   
   func defaultNotifications() -> [String] {
      let notifs: [String] = [
         "Time to XX! Consistency is key to success.",
         "Reminder: It's time to XX. Keep up the good work!",
         "Don't forget to XX today. Remember, small steps lead to big results.",
         "A friendly nudge: It's time to XX. You've got this!",
         "It's XX time! Stick with it, and you'll see progress in no time."
      ]
      return notifs.map { $0.replacingOccurrences(of: "XX", with: habit.name.lowercased()) }
   }
   
   func parseGPTAnswerIntoArray(_ jsonString: String) -> [String]? {
      guard let data = jsonString.data(using: .utf8) else {
         print("Error converting ChatGPT JSON string to Data.")
         return nil
      }
      
      do {
         let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
         guard let jsonDictionary = jsonObject as? [String: Any],
               let notificationsArray = jsonDictionary["notifications"] as? [String] else {
            print("Error parsing ChatGPT JSON object.")
            return nil
         }
         
         return notificationsArray
      } catch {
         print("Error deserializing JSON data: \(error.localizedDescription)")
         return nil
      }
   }
   
   func getAINotifications(_ n: Int, adjective: String, level: Int = 0) async throws -> [String]? {
      guard level <= 3 else { return nil }
      
      try Task.checkCancellation()
      
      var list: [String] = []
      var answer: String!
      print("Fetching \(n) \(adjective) notifications for habit \(habit.name) from ChatGPT... level: \(level)")
      do {
         let chatGPTAnswer = try await OpenAI.shared.chatModel(prompt: notificationPrompt(n: n, adjective: adjective))
         answer = chatGPTAnswer
      } catch {
         print("Error getting response from ChatGPT: \(error.localizedDescription)")
         return try await getAINotifications(n, adjective: adjective, level: level + 1)
      }
      
      guard let parsedList = parseGPTAnswerIntoArray(answer) else {
         return try await getAINotifications(n, adjective: adjective, level: level + 1)
      }
      list = parsedList
      
      // accept if received 80% or more of requested notifications
      guard list.count >= Int(0.8 * Double(n)) else {
         return try await getAINotifications(n, adjective: adjective, level: level + 1)
      }
      
      list = list.map { $0.trimmingCharacters(in: .whitespaces) }
      
      list.removeAll { $0.isEmpty || $0 == "" }
      
      // Randomize
      list.shuffle()
      
      print("ChatGPT notifications: \(list)")
      return list
   }
   
   func nextDue() -> Date {
      fatalError("Override in subclass")
   }
   
   func generateNotificationContent(message: String) -> UNMutableNotificationContent {
      let content = UNMutableNotificationContent()
      content.title = self.habit.name
      content.body = message
      content.sound = UNNotificationSound.default
      return content
   }
   
   func reset() {
      removePendingNotifications()
      for sn in scheduledNotificationsArray {
         self.removeFromScheduledNotifications(sn)
      }
   }
   
   func completeReset() {
      reset()
      self.unscheduledNotificationStrings.removeAll()
   }
   
   func removePendingNotifications() {
      let localID = id
      Task {
         for i in 0 ..< NotificationManager.MAX_NOTIFS {
            let notifID = "OnePercentBetter&\(localID)&\(i)"
            print("Removing notification \(notifID)")
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notifID])
         }
      }
   }
   
   public override func prepareForDeletion() {
      // Remove pending notification requests
      removePendingNotifications()
      NotificationManager.shared.rebalanceHabitNotifications()
   }
}

// MARK: Generated accessors for scheduledNotifications
extension Notification {

    @objc(insertObject:inScheduledNotificationsAtIndex:)
    @NSManaged public func insertIntoScheduledNotifications(_ value: ScheduledNotification, at idx: Int)

    @objc(removeObjectFromScheduledNotificationsAtIndex:)
    @NSManaged public func removeFromScheduledNotifications(at idx: Int)

    @objc(insertScheduledNotifications:atIndexes:)
    @NSManaged public func insertIntoScheduledNotifications(_ values: [ScheduledNotification], at indexes: NSIndexSet)

    @objc(removeScheduledNotificationsAtIndexes:)
    @NSManaged public func removeFromScheduledNotifications(at indexes: NSIndexSet)

    @objc(replaceObjectInScheduledNotificationsAtIndex:withObject:)
    @NSManaged public func replaceScheduledNotifications(at idx: Int, with value: ScheduledNotification)

    @objc(replaceScheduledNotificationsAtIndexes:withScheduledNotifications:)
    @NSManaged public func replaceScheduledNotifications(at indexes: NSIndexSet, with values: [ScheduledNotification])

    @objc(addScheduledNotificationsObject:)
    @NSManaged public func addToScheduledNotifications(_ value: ScheduledNotification)

    @objc(removeScheduledNotificationsObject:)
    @NSManaged public func removeFromScheduledNotifications(_ value: ScheduledNotification)

    @objc(addScheduledNotifications:)
    @NSManaged public func addToScheduledNotifications(_ values: NSOrderedSet)

    @objc(removeScheduledNotifications:)
    @NSManaged public func removeFromScheduledNotifications(_ values: NSOrderedSet)

}
