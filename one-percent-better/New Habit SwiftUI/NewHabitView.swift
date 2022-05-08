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
            Text("Edit Habit")
                .font(.system(size: 30))
            HabitNameView()
            
            Spacer()
                .frame(height: 40)
            
            // Trackers
            HStack {
                Text("Trackers")
                    .font(.system(size: 25))
                Spacer()
                Button("Add tracker") {
                    // TODO
                }
            }
            .padding(.horizontal)
            
            List {
                
            }
            .frame(height: 100)
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
            Text("Name")
                .font(.system(size: 20))

            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(.gray).opacity(0.2)
                    .frame(height: 35)
                
                HStack {
                    Spacer()
                        .frame(width: 10)
                    
                    TextField(placeholderHabits.randomElement()!, text: $habitName)
                        .font(.system(size: 20))
                }
            }
        }
        .padding(.horizontal)
        .frame(height: 30)
    }
}
