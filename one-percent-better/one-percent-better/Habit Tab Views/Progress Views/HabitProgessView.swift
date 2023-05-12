//
//  HabitProgessView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/18/22.
//

import SwiftUI
import CoreData

struct HabitProgessView: View {

   @EnvironmentObject var vm: ProgressViewModel
   
   init() {
      print("HabitProgessView.init()")
   }
   
   var body: some View {
      let _ = Self._printChanges()
      ScrollView {
         VStack(spacing: 20) {
            YearView(habit: vm.habit)
            
            ForEach(0 ..< vm.habit.trackers.count, id: \.self) { i in
               let reverseIndex = vm.habit.trackers.count - 1 - i
               let tracker = vm.habit.trackers[reverseIndex] as! Tracker
               ProgressCards(tracker: tracker)
            }
            
            CardView {
               CalendarView(habit: vm.habit)
            }
            
            StatisticsCardView(habit: vm.habit)
            Spacer()
         }
      }
   }
}

//struct ProgressView_Previews: PreviewProvider {
//
//   static func progressData() -> Habit {
//      let context = CoreDataManager.previews.mainContext
//
//      let day0 = Date()
//      let day1 = Cal.date(byAdding: .day, value: -1, to: day0)!
//      let day2 = Cal.date(byAdding: .day, value: -2, to: day0)!
//
//      let h1 = try? Habit(context: context, name: "Swimming")
//      h1?.markCompleted(on: day0)
//      h1?.markCompleted(on: day1)
//      h1?.markCompleted(on: day2)
//
//      if let h1 = h1 {
//         let t1 = NumberTracker(context: context, habit: h1, name: "Laps")
//         t1.add(date: day0, value: "3")
//         t1.add(date: day1, value: "2")
//         t1.add(date: day2, value: "1")
//
//         let t2 = ImageTracker(context: context, habit: h1, name: "Progress Pics")
//         let patioBefore = UIImage(named: "patio-before")!
//         t2.add(date: day0, value: patioBefore)
//
////         let t3 =
//      }
//
//      let habits = Habit.habits(from: context)
//      return habits.first!
//   }
//
//   static var previews: some View {
//      let habit = progressData()
//      return(
//         NavigationView {
//            HabitProgessView(habit: habit)
////               .environmentObject(habit)
//               .environmentObject(HabitTabNavPath())
//         }
//      )
//   }
//}
