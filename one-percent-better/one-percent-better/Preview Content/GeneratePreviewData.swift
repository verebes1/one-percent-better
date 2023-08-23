//
//  GeneratePreviewData.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 8/22/23.
//

import Foundation

class GeneratePreviewData {
    
    static func get3Habits() -> [Habit] {
        let context = CoreDataManager.previews.mainContext
        
        let day0 = Date()
        let day1 = Cal.date(byAdding: .day, value: -1, to: day0)!
        let day2 = Cal.date(byAdding: .day, value: -9, to: day0)!
        
        let h1 = try? Habit(context: context, name: "Cook")
        h1?.markCompleted(on: day0)
        h1?.markCompleted(on: day1)
        h1?.markCompleted(on: day2)
        
        let h2 = try? Habit(context: context, name: "Clean")
        h2?.markCompleted(on: day1)
        h2?.markCompleted(on: day2)
        
        let h3 = try? Habit(context: context, name: "Laundry")
        h3?.markCompleted(on: day2)
        
        let habits = Habit.habits(from: context)
        return habits
    }
}
