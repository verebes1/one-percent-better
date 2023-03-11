//
//  Notification.swift
//  
//
//  Created by Jeremy Cook on 3/5/23.
//
//

import Foundation
import CoreData

@objc(Notification)
public class Notification: NSManagedObject {
   @nonobjc public class func fetchRequest() -> NSFetchRequest<Notification> {
       return NSFetchRequest<Notification>(entityName: "Notification")
   }

   @NSManaged public var id: UUID
   
   @NSManaged public var habit: Habit?
   
   /// This array contains the scheduled notifications body messages. This array is paired with scheduledNotificationDates
   @NSManaged public var scheduledNotificationStrings: [String]
   
   /// This array contains the scheduled notifications dates. This array is paired with scheduledNotificationStrings
   @NSManaged public var scheduledNotificationDates: [Date]
   
   /// This array contains notification strings that can be used in the future, so that we don't need to call OpenAI every time.
   /// Instead, OpenAI is called in batches (for ex: give me 10 notifications), and the overflow notifications are stored here
   @NSManaged public var unscheduledNotificationStrings: [String]
}
