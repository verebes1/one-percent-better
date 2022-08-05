//
//  HabitCompletionCircle.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/23/22.
//

import SwiftUI

struct HabitCompletionCircle: View {
    
    @ObservedObject var vm: HabitRowViewModel
    
    var color: Color = .green
    var size: CGFloat = 100
    var startColor = Color( #colorLiteral(red: 0.2066814005, green: 0.7795598507, blue: 0.349144876, alpha: 1) )
    var endColor = Color( #colorLiteral(red: 0.4735379219, green: 1, blue: 0.5945096612, alpha: 1) )
    
    @State var show: Bool = false
    
    var body: some View {
        ZStack {
            
            let wasCompleted = vm.habit.wasCompleted(on: vm.currentDay) ? 1.0 : 0.0
//            let timeTrackerValue =
            let percent = vm.habit.hasTimeTracker ? vm.timePercentComplete : wasCompleted
            
            GradientRing(percent: percent,
                         startColor: startColor,
                         endColor: endColor,
                         size: size)
                .animation(.easeInOut, value: percent)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if !vm.habit.manualTrackers.isEmpty {
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
                    if vm.habit.wasCompleted(on: vm.currentDay) {
                        vm.habit.markNotCompleted(on: vm.currentDay)
                    } else {
                        vm.habit.markCompleted(on: vm.currentDay)
                        HapticEngineManager.playHaptic()
                    }
                }
            }
        }
        .sheet(isPresented: self.$show) {
            let enterDataVM = EnterTrackerDataViewModel(habit: vm.habit, currentDay: vm.currentDay)
            EnterTrackerDataView(vm: enterDataVM)
        }
    }
}

struct HabitCompletionCircle_Previews: PreviewProvider {
    
    @State static var currentDay = Date()
    
    static func data() -> [Habit] {
        let context = CoreDataManager.previews.persistentContainer.viewContext
        
        let _ = try? Habit(context: context, name: "Racquetball")
        let h2 = try? Habit(context: context, name: "Jogging")
        h2?.markCompleted(on: Date())
        
        let h3 = try? Habit(context: context, name: "Soccer")
        if let h3 = h3 {
            let _ = NumberTracker(context: context, habit: h3, name: "Hours")
        }
        
        let habits = Habit.habitList(from: context)
        
        return habits
    }
    
    static var previews: some View {
        
        let habits = data()
        
        VStack {
            Text("Not completed")
            let notCompletedHabit = habits[0]
            let vm1 = HabitRowViewModel(habit: notCompletedHabit,
                                        currentDay:
                                            currentDay)
            HabitCompletionCircle(vm: vm1)
                .border(Color.black, width: 1)
            
            Spacer()
                .frame(height: 30)
            
            Text("Completed")
            let completedHabit = habits[1]
            let vm2 = HabitRowViewModel(habit: completedHabit,
                                        currentDay:
                                            currentDay)
            HabitCompletionCircle(vm: vm2)
                .environmentObject(completedHabit)
                .border(Color.black, width: 1)
            
            Spacer()
                .frame(height: 30)
            
            Text("With Tracker")
            let trackerHabit = habits[2]
            let vm3 = HabitRowViewModel(habit: trackerHabit,
                                                    currentDay:
                                                        currentDay)
            HabitCompletionCircle(vm: vm3)
                .environmentObject(trackerHabit)
                .border(Color.black, width: 1)
        }
    }
}
