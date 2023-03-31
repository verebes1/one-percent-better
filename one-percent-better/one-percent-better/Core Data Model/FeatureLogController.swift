//
//  FeatureLogController.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 1/21/22.
//

import Foundation
import CoreData
import UIKit

class FeatureLogController {
   
   static var shared = FeatureLogController()
   
   var featureLog: FeatureLog!
   
   static let improvementTrackerName = "Improvement"
   
   var context = CoreDataManager.shared.mainContext
   
   init() {
      var featureLogs: [FeatureLog] = []
      do {
         // fetch all feature logs (should only be 1)
         let fetchRequest: NSFetchRequest<FeatureLog> = FeatureLog.fetchRequest()
         featureLogs = try context.fetch(fetchRequest)
      } catch {
         fatalError("FeatureLogController.swift \(#function) - unable to fetch feature log! Error: \(error)")
      }
      
      if featureLogs.isEmpty {
         self.featureLog = FeatureLog(context: context)
      } else if featureLogs.count == 1 {
         self.featureLog = featureLogs[0]
      } else {
         fatalError("Too many feature logs")
      }
   }
   
   func setUp() {
      refetchFeatureLog()
      setUpSettings()
      
      setUpID()
      setUpTimesCompleted()
      setUpPercentImprovementTrackers()
      setUpTrackerToHabitRelationships()
      setUpTrackerIndices()
      setUpFrequencyDates()
      setUpNewImprovement()
      setUpTimesPerWeekFrequency()
      setUpNewImprovementScore()
      
      // TODO: TEMP 1.0.9
//      resetNotifications()
   }
   
   func refetchFeatureLog() {
      var featureLogs: [FeatureLog] = []
      do {
         // fetch all feature logs (should only be 1)
         let fetchRequest: NSFetchRequest<FeatureLog> = FeatureLog.fetchRequest()
         featureLogs = try context.fetch(fetchRequest)
      } catch {
         fatalError("FeatureLogController.swift \(#function) - unable to fetch feature log! Error: \(error)")
      }
      
      if featureLogs.isEmpty {
         self.featureLog = FeatureLog(context: context)
      } else if featureLogs.count == 1 {
         self.featureLog = featureLogs[0]
      } else {
         fatalError("Too many feature logs")
      }
   }
   
   func setUpSettings() {
      var settings: [Settings] = []
      do {
         settings = try context.fetch(Settings.fetchRequest())
      } catch {
         assertionFailure("Unable to fetch Settings entity")
         return
      }
      
      if settings.isEmpty {
         let _ = Settings(myContext: context)
         setUpSettings()
         return
      }
      
      guard settings.count == 1 else {
         assertionFailure("Wrong count of settings")
         return
      }
   }
   
   func resetNotifications() {
      let habits = Habit.habits(from: context)
      
//      let pendingNotifi
      
      UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
         print("JJJJ notification requests pending: \(requests)")
      }
      
      for habit in habits {
         let notifs = habit.notificationsArray
         for notif in notifs {
            let id = notif.id
            for i in 0 ..< 20 {
               let notifID = "OnePercentBetter-\(id)-\(i)"
               print("Removing notification \(notifID)")
               UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notifID])
            }
         }
      }
   }
   
   /// Add percent improvement trackers if the user doesn't have them already
   func setUpPercentImprovementTrackers() {
      if !featureLog.hasImprovement {
         let habits = Habit.habits(from: context)
         
         for habit in habits {
            let hasImprovementTracker = habit.trackers.first(where: { tracker in
               if let _ = tracker as? ImprovementTracker {
                  return true
               }
               return false
            }) as? ImprovementTracker
            
            if hasImprovementTracker != nil {
               continue
            }
            
            // Create the improvement tracker and add to autoTrackers
            let improvementTracker = ImprovementTracker(context: context, habit: habit)
            habit.addToTrackers(improvementTracker)
//            improvementTracker.createData(from: nil)
         }
         
         featureLog.hasImprovement = true
         CoreDataManager.shared.saveContext()
      }
   }
   
   func setUpTrackerToHabitRelationships() {
      featureLog.hasTrackerToHabitRelationship = false
      if !featureLog.hasTrackerToHabitRelationship {
         let habits = Habit.habits(from: context)
         
         for habit in habits {
            for tracker in habit.trackers {
               if let t = tracker as? Tracker {
                  t.habit = habit
               }
            }
         }
         
         featureLog.hasTrackerToHabitRelationship = true
         CoreDataManager.shared.saveContext()
      }
   }
   
   func setUpTrackerIndices() {
      if !featureLog.hasTrackerIndices {
         let habits = Habit.habits(from: context)
         
         // Put improvement tracker first
         for habit in habits {
            for tracker in habit.trackers {
               if let t = tracker as? ImprovementTracker {
                  t.index = 0
               }
            }
         }
         
         // Then order the rest of the trackers
         for habit in habits {
            var count = 1
            for tracker in habit.trackers {
               if let _ = tracker as? ImprovementTracker {
                  continue
               } else if let t = tracker as? Tracker {
                  t.index = count
                  count += 1
               }
            }
         }
         
         // Sort trackers in their habit's NSOrderedSet property
         for habit in habits {
            habit.sortTrackers()
         }
         
         featureLog.hasTrackerIndices = true
         CoreDataManager.shared.saveContext()
      }
   }
   
   func setUpTimesCompleted() {
      if !featureLog.hasTimesCompleted {
         let habits = Habit.habits(from: context)
         for habit in habits {
            habit.timesCompleted = Array(repeating: 1, count: habit.daysCompleted.count)
         }
         
         featureLog.hasTimesCompleted = true
         CoreDataManager.shared.saveContext()
      }
   }
   
   func setUpFrequencyDates() {
      if !featureLog.hasFrequencyDates {
         let habits = Habit.habits(from: context)
         for habit in habits {
            if habit.frequencyDates.isEmpty {
               habit.frequencyDates = Array(repeating: habit.startDate, count: habit.frequency.count)
            }
         }
         
         featureLog.hasFrequencyDates = true
         CoreDataManager.shared.saveContext()
      }
   }
   
   func setUpID() {
      if !featureLog.hasID {
         
         let habits = Habit.habits(from: context)
         for habit in habits {
            habit.id = UUID()
         }
         
         featureLog.hasID = true
         CoreDataManager.shared.saveContext()
      }
   }
   
   func setUpNewImprovement() {
      if !featureLog.hasNewImprovement {
         
         let habits = Habit.habits(from: context)
         for habit in habits {
            if let t = habit.improvementTracker {
               t.dates = []
               t.values = []
               t.scores = []
               t.update(on: habit.startDate)
            }
         }
         
         featureLog.hasNewImprovement = true
         CoreDataManager.shared.saveContext()
      }
   }
   
   /// With 1.0.8, there's a new frequency "Times Per Week". Each frequency
   /// has an array to keep track of it's history, and each frequency array needs to be
   /// of the same length as all the other frequency arrays.
   func setUpTimesPerWeekFrequency() {
      if !featureLog.hasTimesPerWeekFrequency {
         
         let habits = Habit.habits(from: context)
         for habit in habits {
            let freqLength = habit.timesPerDay.count
            habit.timesPerWeekTimes = Array(repeating: 1, count: freqLength)
            habit.timesPerWeekResetDay = Array(repeating: Weekday.sunday.rawValue, count: freqLength)
         }
         
         featureLog.hasTimesPerWeekFrequency = true
         CoreDataManager.shared.saveContext()
      }
   }
   
   func setUpNewImprovementScore() {
      if !featureLog.hasNewImprovementScore {
         let habits = Habit.habits(from: context)
         for habit in habits {
            habit.improvementTracker?.recalculateScoreFromBeginning()
         }
         
         featureLog.hasNewImprovementScore = true
         CoreDataManager.shared.saveContext()
      }
   }
}
