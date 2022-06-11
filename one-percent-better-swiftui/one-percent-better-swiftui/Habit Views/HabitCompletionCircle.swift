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
    
    @State var show: Bool = false
    
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 1)
                .stroke(Color.gray.opacity(0.25), style: .init(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .rotation3DEffect(.init(degrees: 180), axis: (x: 1, y: 0, z: 0))
                .rotation3DEffect(.init(degrees: -90), axis: (x: 0, y: 0, z: 1))
                .frame(width: size, height: size)
            
            Circle()
                .trim(from: habit.wasCompleted(on: currentDay) ? 0.01 : 1, to: 1)
                .stroke(color, style: .init(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .rotation3DEffect(.init(degrees: 180), axis: (x: 1, y: 0, z: 0))
                .rotation3DEffect(.init(degrees: -90), axis: (x: 0, y: 0, z: 1))
                .frame(width: size, height: size)
                .animation(.easeInOut, value: habit.wasCompleted(on: currentDay))
        }
        .padding(lineWidth/2)
        .contentShape(Rectangle())
        .onTapGesture {
            
            if !habit.manualTrackers.isEmpty {
                show = true
            } else {
                withAnimation {
                    if habit.wasCompleted(on: currentDay) {
                        habit.markNotCompleted(on: currentDay)
                    } else {
                        habit.markCompleted(on: currentDay)
                    }
                }
            }
        }
        .sheet(isPresented: self.$show) {
            let vm = EnterTrackerDataViewModel(habit: habit)
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
