//
//  MigrationModel18to19.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 6/5/23.
//

import Foundation
import CoreData

// One_Percent_Better.MigrationModel18to19
class MigrationModel18to19: NSEntityMigrationPolicy {
   
   // Old Frequency Data Structure
   // frequencyDates: [Date] - LIST OF DATES OF WHEN FREQUENCY CHANGES
   // Use index of frequencyDates in order to get frequency data
   // All frequency data must be appended to keep the same length as frequencyDates array
   //
   // Example:
   // 1/1/2022  - Habit created with   1 time per day
   // 1/5/2022  - freq changed to      2 times per day
   // 1/14/2022 - freq changed to      MWF
   // 2/3/2022  - freq changed to      3 times per day
   //
   // frequencyDates = [1/1/2022, 1/5/2022, 1/14/2022, 2/3/2022]
   // frequency      = [0,        0,        1,         0       ]
   // timesPerDay    = [1,        2,        1,         3       ]
   // daysPerWeek    = [[0],      [0],      [0,2,4],   [0]     ]
   
   // FUNCTION($entityPolicy, "createFrequenciesForHabit:forHabit:" , $manager, $source)
   @objc func createFrequenciesForHabit(_ manager: NSMigrationManager, forHabit habit: NSManagedObject) -> NSOrderedSet {
      let context = manager.destinationContext
      let habitName = habit.value(forKey: "name")
      print("habitName: \(habitName)")
      
      guard let habitFrequency = habit.value(forKey: "frequency") as? [Int],
            let frequencyDates = habit.value(forKey: "frequencyDates") as? [Date],
            let timesPerDay = habit.value(forKey: "timesPerDay") as? [Int],
            let daysPerWeek = habit.value(forKey: "daysPerWeek") as? [[Int]],
            let timesPerWeekTimes = habit.value(forKey: "timesPerWeekTimes") as? [Int],
            let timesPerWeekResetDay = habit.value(forKey: "timesPerWeekResetDay") as? [Int]
            else {
         assertionFailure("Unable to unwrap habit properties")
         let freqEntity = NSEntityDescription.insertNewObject(forEntityName: "XTimesPerDayFrequency", into: context)
         freqEntity.setValue(1, forKey: "timesPerDay")
         if let destinationHabit = manager.destinationInstances(forEntityMappingName: "HabitToHabit", sourceInstances: [habit]).first {
            // Set the 'habit' relationship to the corresponding Habit in the destination context
            freqEntity.setValue(destinationHabit, forKey: "habit")
         }
         return NSOrderedSet()
      }
      
      var frequencyArray: [NSManagedObject] = []
      
      for i in 0 ..< frequencyDates.count {
         guard let NSFrequency = HabitFrequencyNSManaged(rawValue: habitFrequency[i]) else {
            assertionFailure("Unknown frequency")
            return NSOrderedSet()
         }

         var freqEntity: NSManagedObject
         switch NSFrequency {
         case .timesPerDay:
            freqEntity = NSEntityDescription.insertNewObject(forEntityName: "XTimesPerDayFrequency", into: context)
            freqEntity.setValue(timesPerDay[i], forKey: "timesPerDay")
         case .specificWeekdays:
            freqEntity = NSEntityDescription.insertNewObject(forEntityName: "SpecificWeekdaysFrequency", into: context)
            freqEntity.setValue(daysPerWeek[i], forKey: "weekdays")
         case .timesPerWeek:
            freqEntity = NSEntityDescription.insertNewObject(forEntityName: "XTimesPerWeekFrequency", into: context)
            freqEntity.setValue(timesPerWeekTimes[i], forKey: "timesPerWeek")
            freqEntity.setValue(timesPerWeekResetDay[i], forKey: "resetDay")
         }
         
         let startDate = frequencyDates[i]
         freqEntity.setValue(startDate, forKey: "startDate")
         
         // Get the corresponding Habit in the destination context
         if let destinationHabit = manager.destinationInstances(forEntityMappingName: "HabitToHabit", sourceInstances: [habit]).first {
            // Set the 'habit' relationship to the corresponding Habit in the destination context
            freqEntity.setValue(destinationHabit, forKey: "habit")
         }
         
         frequencyArray.append(freqEntity)
      }
      
      return NSOrderedSet(array: frequencyArray)
   }
}
