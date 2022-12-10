//
//  ExerciseAllEntries.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 9/22/22.
//

import SwiftUI

struct ExerciseAllEntries: View {
    
    var tracker: ExerciseTracker
    
    var entries: [ExerciseEntryModel]
    
    var body: some View {
        Background {
            ScrollView {
                VStack {
                    ForEach(0 ..< entries.count) { i in
                         ExerciseCard(tracker: tracker, vm: entries[i], viewAllButton: false, date: tracker.dates.reversed()[i])
                    }
                }
            }
        }
    }
}

struct ExerciseAllEntries_Previews: PreviewProvider {
    
    static func data() -> ExerciseTracker {
        let context = CoreDataManager.previews.mainContext
        
        let h = try? Habit(context: context, name: "Work Out")
        
        if let h = h {
            let _ = ExerciseTracker(context: context, habit: h, name: "Bench Press")
        }
        
        let habits = Habit.habits(from: context)
        return (habits.first!.trackers.firstObject as! ExerciseTracker)
    }
    
    static var previews: some View {
        let tracker = data()
        let entries = [ExerciseEntryModel(reps: [1,2,3], weights: ["100", "105", "110"]),
                       ExerciseEntryModel(reps: [1,2,3,4], weights: ["105", "110", "115", "120"]),
                       ExerciseEntryModel(reps: [1,2,3], weights: ["100", "105", "110"]),
                       ExerciseEntryModel(reps: [1,2,3], weights: ["100", "105", "110"])]
        ExerciseAllEntries(tracker: tracker, entries: entries)
    }
}
