//
//  Frequency+CoreDataClass.swift
//  
//
//  Created by Jeremy Cook on 6/9/23.
//
//

import Foundation
import CoreData

@objc(Frequency)
public class Frequency: NSManagedObject, Codable {
   
   /// The date the user started using this frequency
   @NSManaged private(set) var startDate: Date
   
   /// The habit this frequency belongs to
   @NSManaged public var habit: Habit
   
   @nonobjc public class func fetchRequest() -> NSFetchRequest<Frequency> {
       return NSFetchRequest<Frequency>(entityName: "Frequency")
   }
   
   func updateStartDate(to startDate: Date) {
      self.startDate = startDate.startOfDay
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
