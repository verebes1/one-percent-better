//
//  CalendarSpacingView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/30/22.
//

import SwiftUI

struct CalendarSpacingView: View {
    
    @EnvironmentObject var habit: Habit
    @State var currentPage: Int = 0
    
    let days: [Day]
    let spacing: CGFloat
    
    var body: some View {
        
        let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 7)
        
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(days, id: \.date) { day in
                CalendarDayView(habit: habit,
                                day: day,
                                fontSize: 13,
                                circleSize: 22)
            }
        }
    }
}

struct CalendarSpacingView_Previews: PreviewProvider {
    
    static func days(weeks: Int) -> [Day] {
        var days: [Day] = []
        var currentDay = Date()
        for _ in 0 ..< weeks {
            for _ in 0 ..< 7 {
                let day = Day(date: currentDay, isWithinDisplayedMonth: true)
                days.append(day)
                currentDay = Calendar.current.date(byAdding: .day, value: -1, to: currentDay)!
            }
        }
        return days
    }
    
    static var previews: some View {
        let context = CoreDataManager.previews.persistentContainer.viewContext
        
        let _ = try? Habit(context: context, name: "A")
        
        let habits = Habit.habitList(from: context)
        
        let habit = habits.first!
        
        let four = days(weeks: 4)
        let five = days(weeks: 5)
        let six = days(weeks: 6)
        
        VStack {
            CardView {
                CalendarSpacingView(days: four, spacing: 20)
                    .environmentObject(habit)
                    .frame(height: 240)
            }
            
            CardView {
                CalendarSpacingView(days: five, spacing: 10)
                    .environmentObject(habit)
                    .frame(height: 240)
            }
            
            CardView {
                CalendarSpacingView(days: six, spacing: 2)
                    .environmentObject(habit)
                    .frame(height: 240)
            }
        }
    }
}
