//
//  ExtraSetUp.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 1/21/22.
//

import Foundation
import CoreData
import UIKit

class ExtraSetUp {
    
    var featureLog: FeatureLog!
    
    static let improvementTrackerName = "Improvement"
    
    var context = CoreDataManager.shared.mainContext
    
    init() {
        var featureLogs: [FeatureLog] = []
        do {
            // fetch all habits
            let fetchRequest: NSFetchRequest<FeatureLog> = FeatureLog.fetchRequest()
            featureLogs = try context.fetch(fetchRequest)
        } catch {
            fatalError("ExtraSetUp.swift \(#function) - unable to fetch feature log! Error: \(error)")
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
        setUpPercentImprovementTrackers()
        setUpTrackerToHabitRelationships()
        setUpTrackerIndices()
    }
    
    /// Add percent improvement trackers if the user doesn't have them already
    func setUpPercentImprovementTrackers() {
        if !featureLog.hasPercentImprovement {
            let habits = Habit.updateHabitList(from: context)
            
            for habit in habits {
                let hasImprovementTracker = habit.trackers.first(where: { tracker in
                    if let t = tracker as? NumberTracker,
                       t.name == ExtraSetUp.improvementTrackerName {
                        return true
                    }
                    return false
                }) as? NumberTracker
                
                if hasImprovementTracker != nil {
                    continue
                }
                
                // Create the improvement tracker and add to autoTrackers
                let improvementTracker = ImprovementTracker(context: context, habit: habit)
                habit.addToTrackers(improvementTracker)
                improvementTracker.createData(habit: habit)
            }
            
            featureLog.hasPercentImprovement = true
            CoreDataManager.shared.saveContext()
        }
    }
    
    func setUpTrackerToHabitRelationships() {
        featureLog.hasTrackerToHabitRelationship = false
        if !featureLog.hasTrackerToHabitRelationship {
            let habits = Habit.updateHabitList(from: context)
            
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
            let habits = Habit.updateHabitList(from: context)
            
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
}
