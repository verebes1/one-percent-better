//
//  AllHabitsGraph.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 11/27/22.
//

import SwiftUI
import Charts


struct AllHabitsGraphCard: View {
   
   @EnvironmentObject var vm: HabitListViewModel
   
   @State private var selectedHabits: [Habit] = []
   
   var body: some View {
      CardView {
         VStack {
            CardTitleWithRightDetail("Improvement Scores") {
               Menu {
                  ForEach(vm.habits) { habit in
                     MenuItemWithCheckmarks(value: habit, selections: $selectedHabits)
                  }
               } label: {
                  HStack {
                     Text("Habits")
                     Image(systemName: "chevron.down")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 6)
                  }
                  .fixedSize()
               }
            }
            
            ZStack {
               // TODO: missing case where habit exists but has never been completed
               let graphHeight = 250 + 21 * CGFloat((vm.habits.count - 1) / 3)
               AllHabitsGraph(habits: selectedHabits)
                  .frame(minHeight: graphHeight)
            }
            .frame(width: UIScreen.main.bounds.width - 40)
         }
      }
      .onAppear {
         selectedHabits = vm.habits
      }
   }
}


struct AllHabitsGraph: View {
   
   var habits: [Habit]
   
   // TODO: Move to ImprovementTracker class, or organize with GraphTracker to work with new SwiftUI Charts
   func improvementScore(for habit: Habit) -> [GraphPoint] {
      var r = [GraphPoint]()
      let dates = habit.improvementTracker?.dates ?? []
      let scores = habit.improvementTracker?.scores ?? []
      for i in 0 ..< dates.count {
         r.append(GraphPoint(date: dates[i], value: scores[i]))
      }
      return r
   }
   
   var body: some View {
      Chart {
         ForEach(habits) { habit in
            let data = improvementScore(for: habit)
            ForEach(data, id: \.date) { item in
               LineMark(
                  x: .value("Date", item.date),
                  y: .value("Score", item.value)
               )
               .interpolationMethod(.monotone)
               .foregroundStyle(by: .value("Habit", habit.name))
            }
         }
      }
   }
}

struct AllHabitsGraph_Previews: PreviewProvider {
   
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
      
      if let h3 = h3 {
         let _ = TimeTracker(context: context, habit: h3, goalTime: 10)
      }
      
      let _ = try? Habit(context: context, name: "Twice A Day", frequency: .timesPerDay(2), id: id4)
      
      let habits = Habit.habits(from: context)
      return habits
   }
   
   static var previews: some View {
      let _ = data()
      let moc = CoreDataManager.previews.mainContext
      let hlvm = HabitListViewModel(moc)
      Background {
         AllHabitsGraphCard()
            .environmentObject(hlvm)
            .border(.black.opacity(0.2))
      }
   }
}
