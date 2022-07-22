//
//  HabitCompletionCircle.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/23/22.
//

import SwiftUI

struct HabitCompletionCircle: View {
    @EnvironmentObject var habit: Habit
    
    var currentDay: Date
    var color: Color = .green
    var size: CGFloat = 100
    var lineWidth: CGFloat {
        size/5
    }
    
    var startColor = Color( #colorLiteral(red: 0.2066814005, green: 0.7795598507, blue: 0.349144876, alpha: 1) )
    var endColor = Color( #colorLiteral(red: 0.4735379219, green: 1, blue: 0.5945096612, alpha: 1) )
    
    @State var show: Bool = false
    var vm: GradientRingViewModel
    
    
    init(currentDay: Date, size: CGFloat = 100, startValue: Bool = false) {
        self.currentDay = currentDay
        self.size = size
        self.vm = GradientRingViewModel(percent: startValue ? 1.0 : 0.0)
    }
    
    var body: some View {
        ZStack {
            GradientRing(vm: vm, startColor: startColor, endColor: endColor, size: size)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if !habit.manualTrackers.isEmpty {
                show = true
            } else {
                if habit.wasCompleted(on: currentDay) {
                    habit.markNotCompleted(on: currentDay)
                } else {
                    habit.markCompleted(on: currentDay)
                    HapticEngineManager.playHaptic()
                }
                vm.percent = habit.wasCompleted(on: currentDay) ? 1.0 : 0.0
            }
        }
        .sheet(isPresented: self.$show) {
            let vm = EnterTrackerDataViewModel(habit: habit, currentDay: currentDay)
            EnterTrackerDataView(vm: vm)
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
            HabitCompletionCircle(currentDay: currentDay)
                .environmentObject(notCompletedHabit)
                .border(Color.black, width: 1)
            
            Spacer()
                .frame(height: 30)
            
            Text("Completed")
            let completedHabit = habits[1]
            HabitCompletionCircle(currentDay: currentDay)
                .environmentObject(completedHabit)
                .border(Color.black, width: 1)
            
            Spacer()
                .frame(height: 30)
            
            Text("With Tracker")
            let trackerHabit = habits[2]
            HabitCompletionCircle(currentDay: currentDay)
                .environmentObject(trackerHabit)
                .border(Color.black, width: 1)
        }
    }
}
