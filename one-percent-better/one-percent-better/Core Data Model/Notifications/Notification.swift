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
    var scheduledNotificationsArray: [ScheduledNotification] { scheduledNotifications?.array as? [ScheduledNotification] ?? [] }
    
    /// This array contains notification strings that can be used in the future, so that we don't make an API call to OpenAI for every notification.
    /// Instead, OpenAI is called in batches (for ex: give me 10 notifications for habit X), and the overflow notifications are stored here
    @NSManaged public var unscheduledNotificationStrings: [String]
    
    var moc: NSManagedObjectContext = CoreDataManager.shared.mainContext
    
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
        moc.performAndWait {
            for i in 0 ..< NotificationManager.MAX_NOTIFS {
                let notifID = "OnePercentBetter&\(id)&\(i)"
                print("Removing notification \(notifID)")
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notifID])
            }
        }
    }
    
    public override func prepareForDeletion() {
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
