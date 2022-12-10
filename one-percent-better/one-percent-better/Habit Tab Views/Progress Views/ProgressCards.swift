//
//  ProgressCards.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/21/22.
//

import SwiftUI

struct ProgressCards: View {
   
   var tracker: Tracker
   
   var body: some View {
      ZStack {
         if let it = tracker as? ImprovementTracker {
            ImprovementGraphCardView(it: it)
         } else if let t = tracker as? GraphTracker {
            GraphCardView(tracker: t)
         } else if let t = tracker as? ImageTracker {
            let vm = ImageCardViewModel(imageTracker: t)
            ImageCardView(vm: vm)
         } else if let t = tracker as? TimeTracker {
            CardView {
               Text("Time tracker: \(t.name), goalTime: \(t.goalTime)")
            }
         } else if let t = tracker as? ExerciseTracker {
//            let vm = t.getPreviousEntry(before: Date(), allowSameDay: true)
//            ExerciseCard(tracker: t, vm: vm)
            ExerciseGraphCard(tracker: t)
         }
      }
   }
}

struct ProgressCards_Previews: PreviewProvider {
   
   static func data() -> Tracker {
      let context = CoreDataManager.previews.mainContext
      
      let day0 = Date()
      let day1 = Cal.date(byAdding: .day, value: -1, to: day0)!
      let day2 = Cal.date(byAdding: .day, value: -2, to: day0)!
      
      let h1 = try? Habit(context: context, name: "Swimming")
      h1?.markCompleted(on: day0)
      h1?.markCompleted(on: day1)
      h1?.markCompleted(on: day2)
      
      if let h1 = h1 {
         let t1 = NumberTracker(context: context, habit: h1, name: "Laps")
         t1.add(date: day0, value: "3")
         t1.add(date: day1, value: "2")
         t1.add(date: day2, value: "1")
         
         let t2 = ImageTracker(context: context, habit: h1, name: "Progress Pics")
         let patioBefore = UIImage(named: "patio-before")!
         t2.add(date: day0, value: patioBefore)
      }
      
      let habits = Habit.habits(from: context)
      return habits.first!.trackers[0] as! Tracker
   }
   
   static var previews: some View {
      let tracker = data()
      ProgressCards(tracker: tracker)
   }
}
