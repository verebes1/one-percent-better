//
//  Tracker+CoreDataClass.swift
//
//
//  Created by Jeremy on 4/11/21.
//
//

import Foundation
import CoreData
import UIKit

@objc(Tracker)
public class Tracker: NSManagedObject, Codable, Identifiable {
    
    /// Unique identifier
    public var id: UUID = UUID()
    
    var context: NSManagedObjectContext = CoreDataManager.shared.mainContext
    
    /// The habit this tracker is attached to
    @NSManaged public var habitNS: HabitNS
    
    /// Name of the tracker
    @NSManaged public var name: String
    
    /// Whether or not the tracker needs manual entry from the user in HabitEntryVC
    @NSManaged public var autoTracker: Bool
    
    /// The order index of the tracker
    @NSManaged public var index: Int
    
    func toString() -> String {
        return "Tracker"
    }
    
    func add<T>(dates: inout [Date], values: inout [T], date: Date, value: T) {
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
    
    func remove(on date: Date) {
        if let t = self as? NumberTracker {
            t.remove(on: date)
        } else if let t = self as? ImageTracker {
            t.remove(on: date)
        }
        context.fatalSave()
    }
    
    func remove<T>(dates: inout [Date], values: inout [T], date: Date) {
        if let index = dates.firstIndex(where: {day in Calendar.current.isDate(day, inSameDayAs: date) }) {
            dates.remove(at: index)
            values.remove(at: index)
        }
    }
    
    func getValue<T>(dates: inout [Date], values: inout [T], date: Date) -> T? {
        if let i = dates.firstIndex(where: {Calendar.current.isDate($0, inSameDayAs: date)}){
            return values[i]
        } else {
            return nil
        }
    }
    
    // MARK: - Encodable
    
    /// Method to conform to Decodable, but should not be used
    /// - Parameter decoder: decoder
    required convenience public init(from decoder: Decoder) throws {
        fatalError("Decoder on \(#file) should not be called")
    }
    
    /// Method to conform to Encodable, but should not be used
    /// - Parameter encoder: encoder
    public func encode(to encoder: Encoder) throws {
        fatalError("Encoder on \(#file) should not be called")
    }
}
