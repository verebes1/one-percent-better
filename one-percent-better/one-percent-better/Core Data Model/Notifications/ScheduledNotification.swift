//
//  ScheduledNotification.swift
//  
//
//  Created by Jeremy Cook on 3/15/23.
//
//

import Foundation
import CoreData

@objc(ScheduledNotification)
public class ScheduledNotification: NSManagedObject {
   @NSManaged public var index: Int
   @NSManaged public var date: Date
   @NSManaged public var string: String
   @NSManaged public var notification: Notification
   @NSManaged public var isScheduled: Bool
   
   convenience init(context: NSManagedObjectContext, index: Int, date: Date, string: String, notification: Notification) {
      self.init(context: context)
      self.index = index
      self.date = date
      self.string = string
      self.notification = notification
      self.isScheduled = true
   }
}

extension ScheduledNotification: HasFetchRequest {
   static func fetchRequest<ScheduledNotification>() -> NSFetchRequest<ScheduledNotification> {
      return NSFetchRequest<ScheduledNotification>(entityName: "ScheduledNotification")
   }
}
