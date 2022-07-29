//
//  HabitRow.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 7/29/22.
//

import SwiftUI


class HabitRowViewModel: ObservableObject {
    let habit: Habit
    let currentDay: Date
    
    init(habit: Habit, currentDay: Date) {
        self.habit = habit
        self.currentDay = currentDay
    }
    
    /// Current streak (streak = 1 if completed today, streak = 2 if completed today and yesterday, etc.)
    var streak: Int {
        get {
            var streak = 0
            // start at yesterday, a streak is only broken if it's not completed by the end of the day
            var day = Calendar.current.date(byAdding: .day, value: -1, to: currentDay)!
            while habit.wasCompleted(on: day) {
                streak += 1
                day = Calendar.current.date(byAdding: .day, value: -1, to: day)!
            }
            // add 1 if completed today
            if habit.wasCompleted(on: currentDay) {
                streak += 1
            }
            return streak
        }
    }
    
    var notDoneIn: Int {
        var difference = 0
        var day = Calendar.current.startOfDay(for: currentDay)
        day = Calendar.current.date(byAdding: .day, value: -1, to: day)!
        if day > habit.startDate {
            while !habit.wasCompleted(on: day) {
                difference += 1
                day = Calendar.current.date(byAdding: .day, value: -1, to: day)!
                if day < habit.startDate {
                    break
                }
            }
            return difference
        } else {
            return -1
        }
    }

    /// Streak label used in habit view
    var streakLabel: String {
        if streak > 0 {
            return "\(streak) day streak"
        } else if habit.daysCompleted.isEmpty || notDoneIn == -1 {
            return "Never done"
        } else {
            let diff = notDoneIn
            let dayText = diff == 1 ? "day" : "days"
            return "Not done in \(diff) \(dayText)"
        }
    }

    /// Color of streak label used in habit view
    var streakLabelColor: Color {
        if streak > 0 {
            return .green
        } else if habit.daysCompleted.isEmpty || notDoneIn == -1 {
            return Color(hue: 1.0, saturation: 0.0, brightness: 0.519)
        } else {
            return .red
        }
    }
}

struct HabitRow: View {
    
    @ObservedObject var vm: HabitRowViewModel
    
    var body: some View {
        HStack {
            VStack {
                HabitCompletionCircle(currentDay: vm.currentDay,
                                      size: 28)
            }
            VStack(alignment: .leading) {
                
                Text(vm.habit.name)
                    .font(.system(size: 16))
                
                Text(vm.streakLabel)
                    .font(.system(size: 11))
                    .foregroundColor(vm.streakLabelColor)
            }
            Spacer()
        }
    }
}

struct HabitRow_Previews: PreviewProvider {
    
    static var habit: Habit = {
        let context = CoreDataManager.previews.persistentContainer.viewContext
        
        let day0 = Date()
        let h1 = try? Habit(context: context, name: "Swimming")
        h1?.markCompleted(on: day0)
        
        let habits = Habit.habitList(from: context)
        return habits.first!
    }()
    
    static var previews: some View {
        let vm = HabitRowViewModel(habit: habit, currentDay: Date())
        HabitRow(vm: vm)
    }
}
