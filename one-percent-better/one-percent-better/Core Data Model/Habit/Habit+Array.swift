//
//  Habit+Array.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 8/29/23.
//

import Foundation
import CoreData

extension Array where Element == Habit {
    /// Date of the earliest start date for a list of habits
    var earliestStartDate: Date {
        var earliest = Date()
        for habit in self {
            if habit.startDate < earliest {
                earliest = habit.startDate
            }
        }
        return earliest
    }
    
    /// Get the percent completion of all habits on this day
    /// - Parameter day: The day to calculate the percent completion for
    /// - Returns: The percent completion as a decimal in range [0,1]
    func percentCompletion(on day: Date) -> Double {
        var numCompleted: Double = 0
        var total: Double = 0
        for habit in self {
            if Cal.startOfDay(for: habit.startDate) <= Cal.startOfDay(for: day),
               habit.isDue(on: day) {
                total += 1
            }
        }
        guard total > 0 else { return 0 }
        
        for habit in self {
            if Cal.startOfDay(for: habit.startDate) <= Cal.startOfDay(for: day),
               habit.isDue(on: day) {
                numCompleted += habit.percentCompleted(on: day)
            }
        }
        return numCompleted / total
    }
    
    /// Delete all habits from the managed object context
    /// - Parameter context: The context to delete from
    func deleteAll(from context: NSManagedObjectContext) {
        for habit in self {
            context.delete(habit)
            try? context.save()
        }
    }
}
