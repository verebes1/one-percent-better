//
//  XTimesPerWeekFrequency+CoreDataClass.swift
//  
//
//  Created by Jeremy Cook on 6/9/23.
//
//

import Foundation
import CoreData

@objc(XTimesPerWeekFrequency)
public class XTimesPerWeekFrequency: Frequency {

   @nonobjc public class func fetchRequest() -> NSFetchRequest<XTimesPerWeekFrequency> {
       return NSFetchRequest<XTimesPerWeekFrequency>(entityName: "XTimesPerWeekFrequency")
   }

   @NSManaged public var timesPerWeek: Int
   @NSManaged public var resetDay: Int
   
   convenience init(context: NSManagedObjectContext,
                    timesPerWeek: Int,
                    resetDay: Weekday = .sunday) {
      self.init(context: context)
      self.timesPerWeek = timesPerWeek
      self.resetDay = resetDay.rawValue
   }
}
