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

class SubHabit {
    var habit: Habit
    init(habit: Habit) {
        self.habit = habit
    }
}

struct ProgressView: View {
    
    @ObservedObject var vm: ProgressViewModel
    
    @State private var progressActive: Bool = false
    
    @State private var editHabitActive = false
    
    init(habit: Habit) {
        self.vm = ProgressViewModel(habit: habit)
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
                        }
                    }
                    
                    let dest = CreateNewTracker(habit: vm.habit, progressPresenting: $progressActive)
                    NavigationLink(destination: dest,
                                   isActive: $progressActive) {
                        Label("New Tracker", systemImage: "plus.circle")
                    }
                   .isDetailLink(false)
                   .padding(.top, 15)
                    
                    Spacer()
                }
            }
            .navigationTitle(vm.habit.name)
            .navigationBarTitleDisplayMode(.large)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Text("Edit")
//                let subHabit = SubHabit(habit: vm.habit)
//                NavigationLink(value: subHabit) {
//                    Text("Edit")
//                }
//                .navigationDestination(for: SubHabit.self) { habit in
//                    EditHabit(habit: habit, show: $editHabitActive)
//                }
//                .navigationDestination(isPresented: $editHabitActive) {
//                    EditHabit(habit: vm.habit, show: $editHabitActive)
//                }
//                NavigationLink(
//                    destination: dest,
//                    isActive: $editHabitActive) {
//                        Text("Edit")
//                    }
//                    .isDetailLink(false)
            }
        }
    }
}

struct ProgressView_Previews: PreviewProvider {
    
    static func progressData() -> Habit {
        let context = CoreDataManager.previews.persistentContainer.viewContext
        
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
        
        let habits = Habit.habitList(from: context)
        return habits.first!
    }
    
    static var previews: some View {
        let habit = progressData()
        return(
            NavigationView {
                ProgressView(habit: habit)
            }
        )
    }
}
