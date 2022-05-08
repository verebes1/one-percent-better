//
//  NewHabitView.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 5/6/22.
//

import SwiftUI

// MARK: - Main View

struct NewHabitView: View {
    
    var body: some View {
        VStack {
            HabitNameView()
        }
    }
}

struct NewHabitView_Previews: PreviewProvider {
    static var previews: some View {
        NewHabitView()
    }
}

// MARK: - Data Entry Views

struct HabitNameView: View {
    
    @State private var habitName: String = ""
    
    let placeholderHabits = ["Brush teeth", "Wake up early", "Play basketball", "Yoga", "Meditate", "Stretch", "Eat a healthy breakfast", "Eat a healthy lunch", "Eat a healthy dinner", "Clean room", "Floss", "Medications"]
    
    var body: some View {
        HStack {
            Text("Habit")
                .font(.headline)

            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(.gray).opacity(0.2)
                
                HStack {
                    Spacer()
                        .frame(width: 10)
                    
                    TextField(placeholderHabits.randomElement()!, text: $habitName)
                }
            }
        }
        .padding(.horizontal)
        .frame(height: 30)
    }
}
