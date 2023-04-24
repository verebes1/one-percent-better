//
//  HabitProgessView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/18/22.
//

import SwiftUI
import CoreData

enum ProgressViewNavRoute: Hashable {
   case editHabit(Habit)
   case newTracker(Habit)
}

struct HabitProgessView: View {
   
   @EnvironmentObject var nav: HabitTabNavPath
   @EnvironmentObject var habit: Habit
   
   var body: some View {
      let _ = Self._printChanges()
      Background {
         ScrollView {
            VStack(spacing: 20) {
               YearView()

               ForEach(0 ..< habit.trackers.count, id: \.self) { i in
                  let reverseIndex = habit.trackers.count - 1 - i
                  let tracker = habit.trackers[reverseIndex] as! Tracker
                  ProgressCards(tracker: tracker)
               }

               CardView {
                  CalendarView(habit: habit)
               }

               StatisticsCardView(habit: habit)

               NavigationLink(value: ProgressViewNavRoute.newTracker(habit)) {
                  CapsuleLabel(text: "New Tracker", systemImage: "plus")
               }

               Spacer()
            }
         }
         .navigationTitle(habit.name)
         .navigationBarTitleDisplayMode(.large)
      }
      .toolbar {
         ToolbarItem(placement: .navigationBarTrailing) {
            NavigationLink("Edit", value: ProgressViewNavRoute.editHabit(habit))
         }
      }
      .navigationDestination(for: ProgressViewNavRoute.self) { route in
         if case .editHabit(let habit) = route {
            EditHabit(habit: habit)
               .environmentObject(habit)
               .environmentObject(nav)
         }
         
         if case .newTracker(let habit) = route {
            CreateNewTracker(habit: habit)
               .environmentObject(nav)
         }
      }
   }
}

struct ProgressView_Previews: PreviewProvider {
   
   static func progressData() -> Habit {
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
         
//         let t3 = 
      }
      
      let habits = Habit.habits(from: context)
      return habits.first!
   }
   
   static var previews: some View {
      let habit = progressData()
      return(
         NavigationView {
            HabitProgessView()
               .environmentObject(habit)
               .environmentObject(HabitTabNavPath())
         }
      )
   }
}
