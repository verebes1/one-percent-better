//
//  StatisticsCalculator.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 1/11/22.
//

import Foundation

class StatisticsCalculator {
    
    public var numStatistics = 4
    
    func getStatistic(habit: Habit, index: Int) -> Statistic {
        switch index {
        case 0:
            // Current Streak
            let curStreak = habit.streak
            let curStreakString = curStreak == 0 ? "None" : "\(curStreak) \(dayString(curStreak))"
            return Statistic(title: "Current Streak", value: curStreakString)
        case 1:
            // Longest Streak
            let longestStreak = habit.longestStreak
            let longestStreakString = longestStreak == 0 ? "None" : "\(longestStreak) \(dayString(longestStreak))"
            return Statistic(title: "Longest Streak", value: longestStreakString)
        case 2:
            // Times Completed This Year
            var totalTimesThisYear = "None"
            if let firstInYearIndex = habit.daysCompleted.firstIndex(where: { day in Calendar.current.isDate(day, equalTo: Date(), toGranularity: .year) } ) {
                totalTimesThisYear = "\(habit.daysCompleted.count - firstInYearIndex)"
            }
            return Statistic(title: "Times This Year", value: totalTimesThisYear)
        case 3:
            // Total Times Completed
            let times = habit.daysCompleted.count
            let timesString = times == 0 ? "None" : "\(times)"
            return Statistic(title: "Total Times", value: timesString)
        default:
            fatalError("wrong index for statistics cell")
        }
        
    }
    
    func dayString(_ value: Int) -> String {
        return value == 1 ? "day" : "days"
    }
    
}
