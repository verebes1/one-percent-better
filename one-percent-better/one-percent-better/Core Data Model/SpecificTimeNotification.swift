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
   
   convenience init(context: NSManagedObjectContext, time: Date? = nil) {
      self.init(context: context)
      self.id = UUID()
      self.unscheduledNotificationStrings = []
      self.scheduledNotificationDates = []
      self.scheduledNotificationStrings = []
      self.time = time ?? Date()
   }
}
