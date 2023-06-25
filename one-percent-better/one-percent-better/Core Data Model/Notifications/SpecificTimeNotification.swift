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
   
   convenience init(context: NSManagedObjectContext, time: Date = Date()) {
      self.init(context: context)
      super.moc = context
      self.id = UUID()
      self.unscheduledNotificationStrings = []
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
