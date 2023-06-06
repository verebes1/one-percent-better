//
//  MigrationModel18to19.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 6/5/23.
//

import Foundation
import CoreData

class MigrationModel18to19: NSEntityMigrationPolicy {
   @objc func createFrequenciesForHabit(_ manager: NSMigrationManager, forHabit habit: NSManagedObject) -> NSSet {
      print("JJJJ")
      let context = manager.destinationContext
      let frequency = NSEntityDescription.insertNewObject(forEntityName: "Frequency", into: context)
      frequency.setValue(habit, forKey: "habit")
      return NSSet(object: frequency)
   }
}
