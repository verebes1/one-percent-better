//
//  GraphTracker.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 1/26/22.
//
//

import Foundation
import CoreData

@objc(GraphTracker)
public class GraphTracker: Tracker {
   
   /// Dates which have data points
   @NSManaged public var dates: [Date]
   
   /// Data points which align with dates array
   @NSManaged public var values: [String]
   
   func add(date: Date, value: String) {
      // check for duplicate date
      if let dateIndex = dates.sameDayBinarySearch(for: date) {
         values[dateIndex] = value
      } else {
         dates.append(date)
         values.append(value)
         
         // sort both lists by dates
         let combined = zip(dates, values).sorted { $0.0 < $1.0 }
         dates = combined.map { $0.0 }
         values = combined.map { $0.1 }
      }
      context.assertSave()
   }
   
   override func remove(on date: Date) {
      if let index = dates.sameDayBinarySearch(for: date) {
         dates.remove(at: index)
         values.remove(at: index)
      }
      context.assertSave()
   }
   
   func getValue(date: Date) -> String? {
      if let i = dates.sameDayBinarySearch(for: date) {
         return values[i]
      } else {
         return nil
      }
   }
}

extension GraphTracker {
   @nonobjc public class func fetchRequest() -> NSFetchRequest<GraphTracker> {
      return NSFetchRequest<GraphTracker>(entityName: "GraphTracker")
   }
}
