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
public class Frequency: NSManagedObject {
   
   /// The date the user started using this frequency
   @NSManaged public var startDate: Date
   
   /// The habit this frequency belongs to
   @NSManaged public var habit: Habit
   
   @nonobjc public class func fetchRequest() -> NSFetchRequest<Frequency> {
       return NSFetchRequest<Frequency>(entityName: "Frequency")
   }
}
