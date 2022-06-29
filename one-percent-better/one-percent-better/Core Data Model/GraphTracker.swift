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
        if let dateIndex = dates.firstIndex(where: {day in Calendar.current.isDate(day, inSameDayAs: date) }) {
            values[dateIndex] = value
        } else {
            dates.append(date)
            values.append(value)
            
            // sort both lists by dates
            let combined = zip(dates, values).sorted { $0.0 < $1.0 }
            dates = combined.map { $0.0 }
            values = combined.map { $0.1 }
        }
        context.fatalSave()
    }
    
    override func remove(on date: Date) {
        if let index = dates.firstIndex(where: {day in Calendar.current.isDate(day, inSameDayAs: date) }) {
            dates.remove(at: index)
            values.remove(at: index)
        }
        context.fatalSave()
    }
    
    func getValue(date: Date) -> String? {
        if let i = dates.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: date) }) {
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
