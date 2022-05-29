//
//  PreviewData.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/21/22.
//

import Foundation
import CoreData

class PreviewData {
    
    static func habitViewData() {
        let context = CoreDataManager.previews.persistentContainer.viewContext
        
        let _ = try? Habit(context: context, name: "Never completed")
        
        let h1 = try? Habit(context: context, name: "Completed yesterday")
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        h1?.markCompleted(on: yesterday, save: false)
        
        let h2 = try? Habit(context: context, name: "Completed today")
        h2?.markCompleted(on: Date(), save: false)
    }
    
    static func progressViewData() -> Habit {
        let context = CoreDataManager.previews.persistentContainer.viewContext
        
        let _ = try? Habit(context: context, name: "Swimming")
        
        let habits = Habit.updateHabitList(from: context)
        
        return habits.first!
    }
    
    static func habitCompletionCircleData() -> [Habit] {
        let context = CoreDataManager.previews.persistentContainer.viewContext
        
        let _ = try? Habit(context: context, name: "Racquetball")
        let h2 = try? Habit(context: context, name: "Jogging")
        h2?.markCompleted(on: Date())
        
        let habits = Habit.updateHabitList(from: context)
        
        return habits
    }
    
    static func calendarViewData() -> Habit {
        let context = CoreDataManager.previews.persistentContainer.viewContext
        
        let h1 = try? Habit(context: context, name: "Jumping Jacks")
        h1?.markCompleted(on: Date())
        
        let habits = Habit.updateHabitList(from: context)
        
        return habits.first!
    }
}
