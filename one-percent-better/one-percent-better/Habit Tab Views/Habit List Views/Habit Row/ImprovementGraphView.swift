//
//  ImprovementGraphView.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 11/7/22.
//

import SwiftUI
import Charts

extension HabitRowViewModel {
   struct GraphPoint {
       var date: Date
       var value: Double
   }
   
   var improvementArr: [GraphPoint] {
      var result = [GraphPoint]()
      for i in 0 ..< 5 {
         let day = Cal.date(byAdding: .day, value: -i, to: self.currentDay)!
         if let value = habit.improvementTracker?.score(on: day) {
            result.append(GraphPoint(date: day, value: value))
         }
      }
      return result
   }
   
   var improvementRange: ClosedRange<Double> {
      var smallest: Double!
      var largest: Double!
      for gp in improvementArr {
         if smallest == nil { smallest = gp.value }
         if largest == nil { largest = gp.value }
         if gp.value < smallest {
            smallest = gp.value
         }
         if gp.value > largest {
            largest = gp.value
         }
      }
      smallest = smallest ?? 0
      largest = largest ?? 1
      if (largest - smallest) < 5 {
         largest += 5 - (largest - smallest)
      }
      return smallest ... largest
   }
   
   
}

struct ImprovementGraphView: View {
   
//   var habit: Habit
   @EnvironmentObject var vm: HabitRowViewModel
   
   var body: some View {
      Chart {
         ForEach(vm.improvementArr, id: \.date) { item in
                 LineMark(
                     x: .value("Date", item.date),
                     y: .value("Profit B", item.value),
                     series: .value("Company", "B")
                 )
                 .symbol(.circle)
                 .symbolSize(20)
                 .interpolationMethod(.catmullRom)
//                 .interpolationMethod(.cardinal)
//                 .interpolationMethod(.linear)
                 .foregroundStyle(Color.accentColor)
             }
      }
      .chartYScale(domain: vm.improvementRange)
      .chartXAxis(.hidden)
      .chartYAxis(.hidden)
//      .frame(width: 300, height: 200)
   }
}

struct ImprovementGraphView_Previews: PreviewProvider {
   
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
      
      let _ = try? Habit(context: context, name: "Basketball", id: id2)
      
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
      let vm = HabitRowViewModel(moc: moc, habit: hlvm.habits[0], currentDay: Date())
      ImprovementGraphView()
         .environmentObject(vm)
         .frame(width: 300, height: 200)
         .border(.black.opacity(0.2))
   }
}
