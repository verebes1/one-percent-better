//
//  StatisticsCardView.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 12/4/22.
//

import SwiftUI

struct StatisticsCardView: View {
    
    var habit: Habit
    
    struct Statistic {
        let title: String
        let value: String
    }
    
    var statistics: [Statistic] {
        
        var stats: [Statistic] = []
        
        // Current Streak
        let curStreak = habit.streak(on: Date())
        let curStreakString = curStreak == 0 ? "None" : "\(curStreak) \(dayString(curStreak))"
        stats.append(Statistic(title: "Current Streak", value: curStreakString))
        
        // Longest Streak
        //      let longestStreak = habit.longestStreak
        //      let longestStreakString = longestStreak == 0 ? "None" : "\(longestStreak) \(dayString(longestStreak))"
        //      stats.append(Statistic(title: "Longest Streak", value: longestStreakString))
        
        // Times Completed This Year
        var totalTimesThisYear = "None"
        if let firstInYearIndex = habit.daysCompleted.firstIndex(where: { day in Calendar.current.isDate(day, equalTo: Date(), toGranularity: .year) } ) {
            totalTimesThisYear = "\(habit.daysCompleted.count - firstInYearIndex)"
        }
        stats.append(Statistic(title: "Times This Year", value: totalTimesThisYear))
        
        // Total Times Completed
        let times = habit.daysCompleted.count
        let timesString = times == 0 ? "None" : "\(times)"
        stats.append(Statistic(title: "Total Times", value: timesString))
        return stats
    }
    
    func dayString(_ value: Int) -> String {
        return value == 1 ? "day" : "days"
    }
    
    var body: some View {
        CardView {
            VStack {
                CardTitleWithRightDetail("Statistics") {
                    EmptyView()
                }
                
                ForEach(statistics, id: \.title) { stat in
                    VStack {
                        
                        Divider()
                        
                        HStack {
                            Text(stat.title)
                            Spacer()
                            Text(stat.value)
                        }
                        .padding(.horizontal)
                        
                    }
                }
            }
            .padding(.bottom, 10)
        }
    }
}

struct StatisticsCardView_Previews: PreviewProvider {
    
    static func progressData() -> Habit {
        let context = CoreDataManager.previews.mainContext
        let h1 = try? Habit(context: context, name: "Swimming")
        h1?.markCompleted(on: Date())
        h1?.markCompleted(on: Cal.add(days: -1))
        h1?.markCompleted(on: Cal.add(days: -2))
        
        let habits = Habit.habits(from: context)
        return habits.first!
    }
    
    static var previews: some View {
        let habit = progressData()
        Background {
            StatisticsCardView(habit: habit)
        }
    }
}
