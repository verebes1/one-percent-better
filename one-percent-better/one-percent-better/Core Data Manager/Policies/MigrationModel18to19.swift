//
//  MigrationModel18to19.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 6/5/23.
//

import Foundation
import CoreData

class MigrationModel18to19: NSEntityMigrationPolicy {
   @objc func createFrequenciesForHabit(manager: NSMigrationManager, habit: NSManagedObject) -> NSSet {
       // Get the context from the migration manager
       let context = manager.destinationContext

       // Here, create Frequency entities according to your requirements.
       // We're just creating a single example Frequency entity per Habit for this demonstration.
       let frequency = NSEntityDescription.insertNewObject(forEntityName: "Frequency", into: context)
       frequency.setValue(habit, forKey: "habit")
       
       // If there are other fields to populate in the Frequency entity, do that here.
       
       return NSSet(object: frequency)
   }
}
