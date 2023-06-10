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

   @NSManaged public var resetDay: Int64
   @NSManaged public var timesPerWeek: Int64
}
