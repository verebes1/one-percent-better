//
//  HabitCompletionCircle.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/23/22.
//

import SwiftUI

struct HabitCompletionCircle: View {
   
   @EnvironmentObject var vm: HabitRowViewModel
   
   var color: Color = .green
   var size: CGFloat = 100
   var startColor = Color( #colorLiteral(red: 0.2066814005, green: 0.7795598507, blue: 0.349144876, alpha: 1) )
   var endColor = Color( #colorLiteral(red: 0.4735379219, green: 1, blue: 0.5945096612, alpha: 1) )
   
   @Binding var completedPressed: Bool
   
   @State var show: Bool = false
   
   func percentCompleted() -> Double {
      guard let freq = vm.habit.frequency(on: vm.currentDay) else { return 0 }
      
      // TODO: Time tracker
//      let percent = vm.habit.hasTimeTracker ? vm.timePercentComplete : wasCompleted
      
      switch freq {
      case .timesPerDay, .specificWeekdays:
         return vm.habit.percentCompleted(on: vm.currentDay)
      case .timesPerWeek:
         return vm.habit.wasCompleted(on: vm.currentDay) ? 1.0 : 0.0
      }
   }
   
   func handleTap() {
      if !vm.habit.editableTrackers.isEmpty {
         show = true
      } else {
         if let t = vm.habit.timeTracker {
            // toggle the timer
            t.toggleTimer(on: vm.currentDay)
            vm.isTimerRunning.toggle()
            if vm.isTimerRunning {
               vm.hasTimerStarted = true
            } else if t.getValue(on: vm.currentDay) == nil {
               vm.hasTimerStarted = false
            } else if let v = t.getValue(on: vm.currentDay),
                      v == 0 {
               vm.hasTimerStarted = false
            }
         } else {
            vm.habit.toggle(on: vm.currentDay)
         }
      }
   }
   
   var body: some View {
      ZStack {
         
         let percent = percentCompleted()
         
         GradientRing(percent: percent,
                      startColor: startColor,
                      endColor: endColor,
                      size: size)
         .animation(.easeInOut, value: percent)
      }
      .contentShape(Rectangle())
      .onChange(of: completedPressed, perform: { newValue in
         handleTap()
      })
      .sheet(isPresented: self.$show) {
         let enterDataVM = EnterTrackerDataViewModel(habit: vm.habit, currentDay: vm.currentDay)
         EnterTrackerDataView(vm: enterDataVM)
      }
   }
}

struct HabitCompletionCircle_Previews: PreviewProvider {
   static var previews: some View {
      HabitCompletionCircle_Previewer()
   }
}


struct HabitCompletionCircle_Previewer: View {
   
   static let h1id = UUID()
   static let h2id = UUID()
   static let h3id = UUID()
   
   func data() -> [Habit] {
      let context = CoreDataManager.previews.mainContext
      
      let _ = try? Habit(context: context, name: "Racquetball", id: HabitCompletionCircle_Previewer.h1id)
      let h2 = try? Habit(context: context, name: "Jogging", id: HabitCompletionCircle_Previewer.h2id)
      h2?.markCompleted(on: Date())
      
      let h3 = try? Habit(context: context, name: "Soccer", id: HabitCompletionCircle_Previewer.h3id)
      if let h3 = h3 {
         let _ = NumberTracker(context: context, habit: h3, name: "Hours")
      }
      
      let habits = Habit.habits(from: context)
      return habits
   }
   
   var currentDay = Date()
   
   var body: some View {
      
      let habits = data()
      
      VStack {
         Text("Not completed")
         let notCompletedHabit = habits[0]
         let vm1 = HabitRowViewModel(moc: CoreDataManager.previews.mainContext, habit: notCompletedHabit,
                                     currentDay:
                                       currentDay)
         HabitCompletionCircle(completedPressed: .constant(false))
            .environmentObject(vm1)
            .border(Color.black, width: 1)
         
         Spacer()
            .frame(height: 30)
         
//         Text("Completed")
//         let completedHabit = habits[1]
//         let vm2 = HabitRowViewModel(habit: completedHabit,
//                                     currentDay:
//                                       currentDay)
//         HabitCompletionCircle(vm: vm2, completedPressed: .constant(false))
//            .environmentObject(completedHabit)
//            .border(Color.black, width: 1)
//
//         Spacer()
//            .frame(height: 30)
//
//         Text("With Tracker")
//         let trackerHabit = habits[2]
//         let vm3 = HabitRowViewModel(habit: trackerHabit,
//                                     currentDay:
//                                       currentDay)
//         HabitCompletionCircle(vm: vm3, completedPressed: .constant(false))
//            .environmentObject(trackerHabit)
//            .border(Color.black, width: 1)
      }
   }
}
