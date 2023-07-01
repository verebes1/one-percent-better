//
//  SpecificTimeNotification+CoreDataClass.swift
//  
//
//  Created by Jeremy Cook on 3/5/23.
//
//

import Foundation
import CoreData

@objc(SpecificTimeNotification)
public class SpecificTimeNotification: Notification {
   
   @nonobjc public class func fetchRequest() -> NSFetchRequest<SpecificTimeNotification> {
       return NSFetchRequest<SpecificTimeNotification>(entityName: "SpecificTimeNotification")
   }

   @NSManaged public var time: Date
   
   convenience init(context: NSManagedObjectContext,
                    notificationGenerator: NotificationGeneratorDelegate? = nil,
                    time: Date = Date()) {
      self.init(context: context)
      moc = context
      id = UUID()
      self.notificationGenerator = notificationGenerator ?? NotificationGenerator()
      unscheduledNotificationStrings = []
      self.time = time
   }
   
   override func nextDue() -> Date {
      if let last = scheduledNotificationsArray.last {
         // TODO: 1.1.0 Add frequency stuff in here eventually
         let next = Cal.add(days: 1, to: last.date)
         return next
      } else {
         let time = Cal.dateComponents([.hour, .minute], from: time)
         let newDate = Cal.date(time: time, dayMonthYear: Date())
         return newDate
      }
   }
}

//class SpecificTimeNotificationObject: CoreDataTransferObject {
//
//   typealias ManagedObject = SpecificTimeNotification
//   var originalManagedObject: SpecificTimeNotification?
//
//   var id: UUID
//   var habit: Habit
//   var time: Date
//   var scheduledNotifications: [ScheduledNotification]
//   var unscheduledNotificationStrings: [String]
//   var notificationGenerator: NotificationGenerator
//
//   required init(from managedObject: SpecificTimeNotification,
//                 notificationGenerator: NotificationGenerator? = nil) {
//      id = managedObject.id
//      habit = managedObject.habit
//      time = managedObject.time
//      scheduledNotifications = managedObject.scheduledNotificationsArray
//      unscheduledNotificationStrings = managedObject.unscheduledNotificationStrings
//      self.notificationGenerator = notificationGenerator ?? NotificationGenerator(habit: managedObject.habit)
//   }
//
//   func updateManagedObject(in context: NSManagedObjectContext) -> SpecificTimeNotification {
//      let stNotification = originalManagedObject ?? SpecificTimeNotification(context: context)
//      stNotification.id = id
//      stNotification.habit = habit
//      stNotification.time = time
//      stNotification.scheduledNotifications = NSOrderedSet(array: scheduledNotifications)
//      stNotification.unscheduledNotificationStrings = unscheduledNotificationStrings
//      return stNotification
//   }
//}
