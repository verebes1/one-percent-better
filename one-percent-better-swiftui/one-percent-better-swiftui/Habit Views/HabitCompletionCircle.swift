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
        }
        .padding(lineWidth/2)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                if habit.wasCompleted(on: currentDay) {
                    habit.markNotCompleted(on: currentDay)
                } else {
                    habit.markCompleted(on: currentDay)
                }
            }
        }
    }
}

struct HabitCompletionCircle_Previews: PreviewProvider {
    
    @State static var currentDay = Date()
    
    static var previews: some View {
        
        let habits = PreviewData.habitCompletionCircleData()
        
        VStack {
            Text("Not completed")
            let notCompletedHabit = habits.first!
            HabitCompletionCircle(currentDay: currentDay)
                .environmentObject(notCompletedHabit)
                .border(Color.black, width: 1)
            
            Spacer()
                .frame(height: 30)
            
            Text("Completed")
            let completedHabit = habits.last!
            HabitCompletionCircle(currentDay: currentDay)
                .environmentObject(completedHabit)
                .border(Color.black, width: 1)
        }
    }
}
