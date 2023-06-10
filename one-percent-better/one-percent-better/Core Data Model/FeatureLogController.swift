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
   
   var moc = CoreDataManager.shared.mainContext
   
   var featureLog: FeatureLog!
   
   var habits: [Habit] = []
   
   func setUp() {
      guard let featureLog = fetchFeatureLog() else {
         assertionFailure("Unable to fetch FeatureLog entity")
         return
      }
      self.featureLog = featureLog
      
      habits = Habit.habits(from: moc)
      
      setUpSettings()
      setUpID()
      setUpTimesCompleted()
      setUpPercentImprovementTrackers()
      setUpTrackerToHabitRelationships()
      setUpTrackerIndices()
      setUpNewImprovement()
      setUpNewImprovementScore()
      
      moc.assertSave()
   }
   
   func fetchFeatureLog() -> FeatureLog? {
      let featureLogs = moc.fetchArray(FeatureLog.self)
      if featureLogs.isEmpty {
         return FeatureLog(context: moc)
      }
      
      guard featureLogs.count == 1 else {
         assertionFailure("Too many FeatureLog entities")
         return nil
      }
      
      return featureLogs.first
   }
   
   func setUpSettings() {
      let settings = moc.fetchArray(Settings.self)
      if settings.isEmpty {
         let _ = Settings(myContext: moc)
         return
      }
      
      guard settings.count == 1 else {
         assertionFailure("Wrong count of settings")
         return
      }
   }
   
   /// Add percent improvement trackers if the user doesn't have them already
   func setUpPercentImprovementTrackers() {
      if !featureLog.hasImprovement {
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
            let improvementTracker = ImprovementTracker(context: moc, habit: habit)
            habit.addToTrackers(improvementTracker)
         }
         featureLog.hasImprovement = true
      }
   }
   
   func setUpTrackerToHabitRelationships() {
      featureLog.hasTrackerToHabitRelationship = false
      if !featureLog.hasTrackerToHabitRelationship {
         for habit in habits {
            for tracker in habit.trackers {
               if let t = tracker as? Tracker {
                  t.habit = habit
               }
            }
         }
         featureLog.hasTrackerToHabitRelationship = true
      }
   }
   
   func setUpTrackerIndices() {
      if !featureLog.hasTrackerIndices {
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
      }
   }
   
   func setUpTimesCompleted() {
      if !featureLog.hasTimesCompleted {
         for habit in habits {
            habit.timesCompleted = Array(repeating: 1, count: habit.daysCompleted.count)
         }
         featureLog.hasTimesCompleted = true
      }
   }
   
   func setUpID() {
      if !featureLog.hasID {
         for habit in habits {
            habit.id = UUID()
         }
         featureLog.hasID = true
      }
   }
   
   func setUpNewImprovement() {
      if !featureLog.hasNewImprovement {
         for habit in habits {
            if let t = habit.improvementTracker {
               t.dates = []
               t.values = []
               t.scores = []
               t.update(on: habit.startDate)
            }
         }
         featureLog.hasNewImprovement = true
      }
   }
   
   /// With 1.0.8, the improvement score now starts on the start date, not one day before.
   /// This recalculates all the improvement scores
   func setUpNewImprovementScore() {
      if !featureLog.hasNewImprovementScore {
         for habit in habits {
            habit.improvementTracker?.recalculateScoreFromBeginning()
         }
         featureLog.hasNewImprovementScore = true
      }
   }
}
