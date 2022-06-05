//
//  HabitHelper.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/5/22.
//

import Foundation


class HabitHelper {
    
    public static func totalPercent(habits: [Habit], for day: Date) -> Double {
        var numCompleted: Double = 0
        let total: Double = Double(habits.count)
        for habit in habits {
            if habit.wasCompleted(on: day) {
                numCompleted += 1
            }
        }
        return numCompleted / total
    }
    
    public static func earliestStartDate(habits: [Habit]) -> Date {
        var earliest = Date()
        for habit in habits {
            if habit.startDate < earliest {
                earliest = habit.startDate
            }
        }
        return earliest
    }
}
