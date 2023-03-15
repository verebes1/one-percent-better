//
//  RandomTimeNotification+CoreDataClass.swift
//  
//
//  Created by Jeremy Cook on 3/5/23.
//
//

import Foundation
import CoreData

@objc(RandomTimeNotification)
public class RandomTimeNotification: Notification {
   @nonobjc public class func fetchRequest() -> NSFetchRequest<RandomTimeNotification> {
       return NSFetchRequest<RandomTimeNotification>(entityName: "RandomTimeNotification")
   }

   @NSManaged public var startTime: Date
   @NSManaged public var endTime: Date
   
   lazy var startTimeDefault: Date = {
      var components = DateComponents()
      components.hour = 9
      components.minute = 0
      return Cal.date(from: components) ?? Date()
   }()
   
   lazy var endTimeDefault: Date = {
      var components = DateComponents()
      components.hour = 17
      components.minute = 0
      return Cal.date(from: components) ?? Date()
   }()
   
   convenience init(myContext: NSManagedObjectContext, startTime: Date? = nil, endTime: Date? = nil) {
      self.init(context: myContext)
      self.id = UUID()
      self.unscheduledNotificationStrings = []
      self.scheduledNotificationDates = []
      self.scheduledNotificationStrings = []
      self.startTime = startTime ?? startTimeDefault
      self.endTime = endTime ?? endTimeDefault
   }
   
   func nextDue() -> Date {
      if let last = scheduledNotificationDates.last {
         let next = Cal.add(days: 1, to: last)
         return next
      } else {
         let time = Cal.dateComponents([.hour, .minute], from: startTime)
         let newDate = Cal.date(time: time, dayMonthYear: Date())
         return newDate
      }
   }
}
