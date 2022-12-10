//
//  ExerciseGraphCard.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 12/4/22.
//

import SwiftUI
import Charts

struct ExerciseGraphCard: View {
   
   var tracker: ExerciseTracker
   
   func data() -> [GraphPoint] {
      var r = [GraphPoint]()
      
      for i in 0 ..< tracker.dates.count {
         let date = tracker.dates[i]
         let weights = tracker.weights[i]
         let reps = tracker.reps[i]
         
         var volume: Double = 0
         for j in 0 ..< weights.count {
            if let weightDouble = Double(weights[j]) {
               volume += weightDouble * Double(reps[j])
            }
         }
         
         r.append(GraphPoint(date: date, value: volume))
      }
      return r
   }
   
   var body: some View {
      CardView {
         VStack {
            CardTitleWithRightDetail(tracker.name) {
               NavigationLink {
                   ExerciseAllEntries(tracker: tracker, entries: tracker.getAllEntries())
               } label: {
                   HStack {
                       Text("Table")
                       Image(systemName: "chevron.right")
                   }
               }
            }
            
            Chart {
               let data = data()
               ForEach(data, id: \.date) { item in
                  LineMark(
                     x: .value("Date", item.date),
                     y: .value("Volume", item.value)
                  )
                  .symbol(.circle)
                  .symbolSize(14)
//                  .interpolationMethod(.monotone)
               }
            }
            .frame(height: 250)
            .padding()
         }
      }
   }
}

struct ExerciseGraphCard_Previews: PreviewProvider {
   
   static func data() -> ExerciseTracker {
      let context = CoreDataManager.previews.mainContext
      
      let h = try? Habit(context: context, name: "Work Out")
      
      if let h = h {
         let e = ExerciseTracker(context: context, habit: h, name: "Bench Press")
         e.addSet(set: 1, rep: 10, weight: "10", on: Date())
         e.addSet(set: 2, rep: 10, weight: "10", on: Date())
         e.addSet(set: 3, rep: 10, weight: "15", on: Date())
         
         e.addSet(set: 1, rep: 10, weight: "10", on: Cal.addDays(num: -1))
         e.addSet(set: 2, rep: 10, weight: "10", on: Cal.addDays(num: -1))
         e.addSet(set: 3, rep: 10, weight: "10", on: Cal.addDays(num: -1))
         
         e.addSet(set: 1, rep: 10, weight: "5", on: Cal.addDays(num: -2))
         e.addSet(set: 2, rep: 10, weight: "5", on: Cal.addDays(num: -2))
         e.addSet(set: 3, rep: 10, weight: "10", on: Cal.addDays(num: -2))
      }
      
      let habits = Habit.habits(from: context)
      
      let trackers = habits.first?.trackers.array as! [Tracker]
      
      return (trackers.first { $0 is ExerciseTracker }) as! ExerciseTracker
   }
   
   static var previews: some View {
      let tracker = data()
      NavigationStack {
         Background {
            ExerciseGraphCard(tracker: tracker)
         }
      }
   }
}
