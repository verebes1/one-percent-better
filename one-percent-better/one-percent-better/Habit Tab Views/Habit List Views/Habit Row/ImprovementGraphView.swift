//
//  ImprovementGraphView.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 11/7/22.
//

import SwiftUI
import Charts

struct ImprovementGraphView: View {
   
   @EnvironmentObject var vm: HabitRowViewModel
   
   func getLast7() -> [GraphPoint] {
      return vm.habit.improvementTracker?.lastNDays(n: 7, on: vm.currentDay) ?? []
   }
   
   func graphColor(last7: [GraphPoint], avg: Double) -> Color {
      guard !last7.isEmpty else {
         return .gray
      }
      // improvement array in reverse order
      let last = last7.last!.value
      
      if last > avg {
         return Color.green
      } else if avg > last {
         return Color.red
      } else {
         return Color.gray
      }
   }
   
   func improvementRange(last5: [GraphPoint]) -> ClosedRange<Double> {
      var smallest: Double!
      var largest: Double!
      for gp in last5 {
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
   
   func average(last5: [GraphPoint]) -> Double {
      if last5.isEmpty {
         return 0
      }
      var avg: Double = 0
      for gp in last5 {
         avg += gp.value
      }
      avg /= Double(last5.count)
      return avg
   }
   
   var body: some View {
      let last5 = getLast7()
      let average = average(last5: last5)
      Chart {
         RuleMark(y: .value("Average", average))
            .lineStyle(.init(lineWidth: 1, dash: [1,5]))
            .foregroundStyle(.gray.opacity(0.7))
         
         ForEach(last5, id: \.date) { item in
            LineMark(
               x: .value("Date", item.date),
               y: .value("Profit B", item.value),
               series: .value("Company", "B")
            )
            .symbol(.circle)
            .symbolSize(14)
            .interpolationMethod(.monotone)
            .foregroundStyle(graphColor(last7: last5, avg: average).opacity(0.9))
         }
      }
      .animation(.easeInOut, value: last5)
      .chartYScale(domain: improvementRange(last5: last5))
      .chartXAxis(.hidden)
      .chartYAxis(.hidden)
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
      
      let h2 = try? Habit(context: context, name: "Basketball (MWF)", id: id2)
      h2?.changeFrequency(to: .daysInTheWeek([1,3,5,6]))
      h2?.markCompleted(on: Date())
      
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
      let vm = HabitRowViewModel(moc: moc, habit: hlvm.habits[1], currentDay: Date())
      ImprovementGraphView()
         .environmentObject(vm)
         .frame(width: 300, height: 200)
         .border(.black.opacity(0.2))
   }
}
