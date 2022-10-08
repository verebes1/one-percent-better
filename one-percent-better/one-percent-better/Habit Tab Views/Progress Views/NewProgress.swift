//
//  NewProgress.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 9/25/22.
//

//import SwiftUI
//import CoreData
//
//class NewProgressViewModel: ObservableObject {
//
//    @Published var habit: Habit
//    @Published var trackers: [Tracker]
//
//    init(habit: Habit) {
//        self.habit = habit
//        self.trackers = habit.trackers.map { $0 as! Tracker }
//    }
//}
//
//struct NewProgress: View {
//    
//    @ObservedObject var vm: NewProgressViewModel
//    
//    @Binding var progressActive: Bool
//    
//    @State private var createNewTrackerActive = false
//    
//    @State private var editHabitActive = false
//    
//    init(habit: Habit, active: Binding<Bool>) {
//        self.vm = NewProgressViewModel(habit: habit)
//        self._progressActive = active
//    }
//    
//    var body: some View {
//        Background {
//            ScrollView {
//                EmptyView()
//            }
//        }
//        .toolbar {
//            
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Image(systemName: "calendar")
//                    .foregroundColor(Style.accentColor)
//            }
//            
//            ToolbarItem(placement: .navigationBarTrailing) {
//                let dest = EditHabit(habit: vm.habit, show: $editHabitActive)
//                NavigationLink(
//                    destination: dest,
//                    isActive: $editHabitActive) {
//                        Text("Edit")
//                    }
//                    .isDetailLink(false)
//            }
//        }
//    }
//}
//
//struct NewProgressView_Previews: PreviewProvider {
//    
//    static func progressData() -> Habit {
//        let context = CoreDataManager.previews.mainContext
//        
//        let day0 = Date()
//        let day1 = Calendar.current.date(byAdding: .day, value: -1, to: day0)!
//        let day2 = Calendar.current.date(byAdding: .day, value: -2, to: day0)!
//        
//        let h1 = try? Habit(context: context, name: "Swimming")
//        h1?.markCompleted(on: day0)
//        h1?.markCompleted(on: day1)
//        h1?.markCompleted(on: day2)
//        
//        if let h1 = h1 {
//            let t1 = NumberTracker(context: context, habit: h1, name: "Laps")
//            t1.add(date: day0, value: "3")
//            t1.add(date: day1, value: "2")
//            t1.add(date: day2, value: "1")
//            
//            let t2 = ImageTracker(context: context, habit: h1, name: "Progress Pics")
//            let patioBefore = UIImage(named: "patio-before")!
//            t2.add(date: day0, value: patioBefore)
//        }
//        
//        let habits = Habit.habits(from: context)
//        return habits.first!
//    }
//    
//    static var previews: some View {
//        let habit = progressData()
//        return(
//            NavigationView {
//                NewProgress(habit: habit, active: .constant(true))
//            }
//        )
//    }
//}
