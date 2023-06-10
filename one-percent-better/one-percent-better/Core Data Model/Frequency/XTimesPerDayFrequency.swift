//
//  XTimesPerDayFrequency+CoreDataClass.swift
//  
//
//  Created by Jeremy Cook on 6/9/23.
//
//

import Foundation
import CoreData

@objc(XTimesPerDayFrequency)
public class XTimesPerDayFrequency: Frequency {
   @nonobjc public class func fetchRequest() -> NSFetchRequest<XTimesPerDayFrequency> {
       return NSFetchRequest<XTimesPerDayFrequency>(entityName: "XTimesPerDayFrequency")
   }

   @NSManaged public var timesPerDay: Int
   
   convenience init(context: NSManagedObjectContext,
                    timesPerDay: Int) {
      self.init(context: context)
      self.timesPerDay = timesPerDay
   }
}
