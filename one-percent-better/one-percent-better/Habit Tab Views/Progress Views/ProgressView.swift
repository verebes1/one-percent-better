//
//  ProgressView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/18/22.
//

import SwiftUI
import CoreData

class ProgressViewModel: ObservableObject {
  
  @Published var habit: Habit
  @Published var trackers: [Tracker]
  
  init(habit: Habit) {
    self.habit = habit
    self.trackers = habit.trackers.map { $0 as! Tracker }
  }
}

struct ProgressView: View {
  
  @ObservedObject var vm: ProgressViewModel
  
  @Binding var progressActive: Bool
  
  @State private var createNewTrackerActive = false
  
  @State private var editHabitActive = false
  
  private let id = UUID()
  
  init(habit: Habit, active: Binding<Bool>) {
    self.vm = ProgressViewModel(habit: habit)
    self._progressActive = active
  }
  
  var body: some View {
    Background {
      ScrollView {
        VStack(spacing: 20) {
          CardView {
            CalendarView(habit: vm.habit)
          }
          
          ForEach(0 ..< vm.trackers.count, id: \.self) { i in
            let tracker = vm.trackers[i]
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
          
          //          let dest = CreateNewTracker(habit: vm.habit, progressPresenting: $createNewTrackerActive)
          
          //          NavigationLink(destination: dest,
          //                         isActive: $createNewTrackerActive) {
          //            Label("New Tracker", systemImage: "plus.circle")
          //          }
          //                         .isDetailLink(false)
          //                         .padding(.top, 15)
          
          
          Spacer()
        }
      }
      .navigationTitle(vm.habit.name)
      .navigationBarTitleDisplayMode(.large)
    }
    .navigationDestination(for: UUID.self, destination: { id in
      EditHabit(habit: vm.habit)
    })
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        NavigationLink("Edit", value: id)
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
        ProgressView(habit: habit, active: .constant(true))
      }
    )
  }
}
