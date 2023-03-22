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
      guard let array = scheduledNotifications?.array as? [ScheduledNotification] else {
         return []
      }
      return array
   }
   
   /// This array contains notification strings that can be used in the future, so that we don't need to call OpenAI every time.
   /// Instead, OpenAI is called in batches (for ex: give me 10 notifications), and the overflow notifications are stored here
   @NSManaged public var unscheduledNotificationStrings: [String]
   
   var moc: NSManagedObjectContext = CoreDataManager.shared.mainContext
   
   func createScheduledNotification(index: Int, on date: Date) async -> String {
      if unscheduledNotificationStrings.isEmpty {
         let messages = await getAINotifications(NotificationManager.MAX_NOTIFS, name: habit.name)
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
   
   func notificationPrompt(n: Int, name: String, adjective: String) -> String {
      return """
            Task: Generate \(n) different examples of a \(adjective) notification to encourage someone to do their habit named "\(name.lowercased())".
            Requirements: For each notification, use between 10 and 60 characters. Return them as a JSON array named "notifications".
            """
   }
   
   func getAINotifications(_ n: Int, name: String, level: Int = 0) async -> [String] {
      var notifs: [String] = []
      let adjectiveArray = ["creative", "funny", "motivating", "inspiring", "funny Gen Z"]
      for i in 0 ..< adjectiveArray.count {
         let count = n / adjectiveArray.count
         let someNotifs = await getAINotifications(count, name: name, adjective: adjectiveArray[i])
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
   
   func getAINotifications(_ n: Int, name: String, adjective: String, level: Int = 0) async -> [String] {
      var list: [String] = []
      guard level <= 3 else { return list }
      print("Getting \(n) notifications from ChatGPT")
      do {
         if let answer = try await OpenAI.shared.chatModel(prompt: notificationPrompt(n: n, name: name, adjective: adjective)) {
            print("ChatGPT \(adjective) answer: \(answer)")
            
            
            guard let jsonList = parseGPTAnswer(answer: answer) else {
               print("ChatGPT answer failed to parse JSON trying again with level: \(level + 1)")
               return await getAINotifications(n, name: name, adjective: adjective, level: level + 1)
            }
            list = jsonList
            //            list = answer.components(separatedBy: ",")
            
            guard list.count >= n else {
               print("ChatGPT answer failed, COUNT = \(list.count) trying again with level: \(level + 1)")
               return await getAINotifications(n, name: name, adjective: adjective, level: level + 1)
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
         return await getAINotifications(n, name: name, adjective: adjective, level: level + 1)
      }
      list.shuffle()
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
      for sn in scheduledNotificationsArray {
         self.removeFromScheduledNotifications(sn)
         moc.delete(sn)
      }
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
