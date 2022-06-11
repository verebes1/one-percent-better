//
//  ProgressView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/18/22.
//

import SwiftUI
import CoreData

class ProgressViewModel: ObservableObject {
    
    var habit: Habit
    var trackers: [Tracker]
    
    init(habit: Habit) {
        self.habit = habit
        self.trackers = habit.trackers.map{ $0 as! Tracker }
    }
}

struct ProgressView: View {
    
    var vm: ProgressViewModel
    
    @State var progressPresenting: Bool = false
    
    var body: some View {
        Background {
            VStack(spacing: 20) {
                CardView {
                    CalendarView()
                }
                
                ForEach(vm.trackers) { tracker in
                    NumberTrackerTableCardView(tracker: tracker)
                }
                
                NavigationLink(destination: CreateTableTracker(habit: vm.habit, progressPresenting: $progressPresenting),
                               isActive: $progressPresenting) {
                    Label("New Tracker", systemImage: "plus.circle")
                }
                .isDetailLink(false)
                .padding(.top, 15)
                
                Spacer()
            }
            .navigationTitle(vm.habit.name)
            .navigationBarTitleDisplayMode(.large)
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
        }
        
        let habits = Habit.habitList(from: context)
        return habits.first!
    }
    
    static var previews: some View {
        
        let habit = progressData()
        
        let vm = ProgressViewModel(habit: habit)
        return(
            NavigationView {
                ProgressView(vm: vm)
                    .preferredColorScheme(.light)
                    .environmentObject(habit)
            }
        )
    }
}
