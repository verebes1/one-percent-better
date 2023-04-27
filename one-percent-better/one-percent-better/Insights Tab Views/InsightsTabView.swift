//
//  InsightsTabView.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 12/6/22.
//

import SwiftUI

struct InsightsTabView: View {
   
   @EnvironmentObject var vm: HabitListViewModel
   
   var body: some View {
      let _ = Self._printChanges()
      Background {
         ScrollView {
            VStack(spacing: 20) {
               AllHabitsGraphCard()
//
               WeeklyPercentGraphCard()
               
//               CardView {
//                  Text("Test Card")
//                     .frame(maxWidth: .infinity)
//               }
            }
         }
      }
      .navigationTitle("Insights")
   }
}

struct InsightsTabView_Previews: PreviewProvider {
   
   static let id1 = UUID()
   static let id2 = UUID()
   static let id3 = UUID()
   static let id4 = UUID()
   
   static func data() -> [Habit] {
      let context = CoreDataManager.previews.mainContext
      
      let h1 = try? Habit(context: context, name: "Swimming", id: id1)
      h1?.markCompleted(on: Cal.date(byAdding: .day, value: -3, to: Date())!)
      h1?.markCompleted(on: Cal.date(byAdding: .day, value: 0, to: Date())!)
      h1?.markCompleted(on: Cal.date(byAdding: .day, value: -1, to: Date())!)
      h1?.markCompleted(on: Cal.add(days: -10))
      h1?.markCompleted(on: Cal.add(days: -11))
      h1?.markCompleted(on: Cal.add(days: -12))
      
      let h2 = try? Habit(context: context, name: "Basketball (MWF)", id: id2)
      h2?.changeFrequency(to: .specificWeekdays([.monday, .wednesday, .friday]))
      h2?.markCompleted(on: Date())
      h2?.markCompleted(on: Cal.add(days: -1))
      
      let h3 = try? Habit(context: context, name: "Timed Habit", id: id3)
      h3?.markCompleted(on: Cal.add(days: -1))
      
      if let h3 = h3 {
         let _ = TimeTracker(context: context, habit: h3, goalTime: 10)
      }
      
      let h4 = try? Habit(context: context, name: "Twice A Day", frequency: .timesPerDay(2), id: id4)
      h4?.markCompleted(on: Cal.add(days: -8))
      
      let habits = Habit.habits(from: context)
      return habits
   }
   
   static var previews: some View {
      let _ = data()
      let moc = CoreDataManager.previews.mainContext
      let hlvm = HabitListViewModel(moc)
      InsightsTabView()
         .environmentObject(hlvm)
   }
}
