//
//  SpecificWeekdaysFrequency+CoreDataClass.swift
//  
//
//  Created by Jeremy Cook on 6/9/23.
//
//

import Foundation
import CoreData

@objc(SpecificWeekdaysFrequency)
public class SpecificWeekdaysFrequency: Frequency {

   @nonobjc public class func fetchRequest() -> NSFetchRequest<SpecificWeekdaysFrequency> {
       return NSFetchRequest<SpecificWeekdaysFrequency>(entityName: "SpecificWeekdaysFrequency")
   }

   @NSManaged public var weekdays: [Int]
   
   convenience init(context: NSManagedObjectContext,
                    weekdays: Set<Weekday>) {
      self.init(context: context)
      self.weekdays = weekdays.map { $0.rawValue }
   }
}
