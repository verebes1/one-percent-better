//
//  ExerciseGraphCard.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 12/4/22.
//

import SwiftUI

struct ExerciseGraphCard: View {
   
   var tracker: ExerciseTracker
   
   var body: some View {
      Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
   }
}

struct ExerciseGraphCard_Previews: PreviewProvider {
   
   static func data() -> ExerciseTracker {
      let context = CoreDataManager.previews.mainContext
      
      let h = try? Habit(context: context, name: "Work Out")
      
      if let h = h {
         let _ = ExerciseTracker(context: context, habit: h, name: "Bench Press")
      }
      
      let habits = Habit.habits(from: context)
      
      let trackers = habits.first?.trackers.array as! [Tracker]
      
      return (trackers.first { $0 is ExerciseTracker }) as! ExerciseTracker
   }
   
   static var previews: some View {
      let tracker = data()
      let vm = ExerciseEntryModel(reps: [8, 10, 12], weights: ["225", "245", "250"])
      Background {
         ExerciseGraphCard(tracker: tracker)
      }
   }
}
