//
//  ProgressView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/18/22.
//

import SwiftUI
import CoreData

enum ProgressViewNavRoute: Hashable {
  case editHabit
  case newTracker
}

struct ProgressView: View {
  
  @EnvironmentObject var habit: Habit
  
  var body: some View {
    Background {
      ScrollView {
        VStack(spacing: 20) {
          CardView {
            CalendarView(habit: habit)
          }
          
          ForEach(0 ..< habit.trackers.count, id: \.self) { i in
            let tracker = habit.trackers[i]
            if let t = tracker as? GraphTracker {
              GraphCardView(tracker: t)
            } else if let t = tracker as? ImageTracker {
              let vm = ImageCardViewModel(imageTracker: t)
              ImageCardView(vm: vm)
            } else if let t = tracker as? TimeTracker {
              CardView {
                Text("Time tracker: \(t.name), goalTime: \(t.goalTime)")
              }
            } else if let t = tracker as? ExerciseTracker {
              let vm = t.getPreviousEntry(before: Date(), allowSameDay: true)
              CardView {
                ExerciseCard(tracker: t, vm: vm)
              }
            }
          }
          
          NavigationLink(value: ProgressViewNavRoute.newTracker) {
            Label("New Tracker", systemImage: "plus.circle")
          }
          .buttonStyle(BorderedButtonStyle())
          .padding(.top, 15)
          
          Spacer()
        }
      }
      .navigationTitle(habit.name)
      .navigationBarTitleDisplayMode(.large)
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        NavigationLink("Edit", value: ProgressViewNavRoute.editHabit)
      }
    }
    .navigationDestination(for: ProgressViewNavRoute.self) { route in
      if route == .editHabit {
        EditHabit(habit: habit)
            .environmentObject(habit)
      }
      
      if route == .newTracker {
        CreateNewTracker(habit: habit)
      }
    }
  }
}

struct ProgressView_Previews: PreviewProvider {
  
  static func progressData() -> Habit {
    let context = CoreDataManager.previews.mainContext
    
    let day0 = Date()
    let day1 = Calendar.current.date(byAdding: .day, value: -1, to: day0)!
    let day2 = Calendar.current.date(byAdding: .day, value: -2, to: day0)!
    
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
    return habits.first!
  }
  
  static var previews: some View {
    let habit = progressData()
    return(
      NavigationView {
        ProgressView()
          .environmentObject(habit)
      }
    )
  }
}
