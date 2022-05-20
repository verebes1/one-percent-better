//
//  CreateNewHabit.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/17/22.
//

import SwiftUI

struct CreateNewHabit: View {
    
    @State var habitName: String = ""
    @State var nextPressed: Bool = false
    var showNameError: Bool {
        return nextPressed && habitName.isEmpty
    }
    
    var body: some View {
        ZStack {
            Background()
            VStack {
                HabitCreationHeader(systemImage: "square.and.pencil",
                                    title: "Create New Habit")
                
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.listColor)
                            .frame(height: 50)
                        HStack {
                            Text("Name")
                                .fontWeight(.semibold)
                                .padding(.leading, 10)
                            TextField("Habit Name", text: $habitName)
                        }
                    }.padding(.horizontal, 15)
                    
                    if showNameError {
                        Label("Enter a habit name", systemImage: "exclamationmark.triangle")
                            .foregroundColor(.red)
                            .animation(.easeInOut, value: nextPressed)
                    }
                }
                
                Spacer()
                
                    
                NavigationLink(destination: CreateNewTracker(habitName: habitName)) {
                    BottomButton(text: "Create")
                }
                .disabled(habitName.isEmpty)
                .onTapGesture {
                    nextPressed = true
                }
                
            }
        }
    }
}

struct CreateNewHabit_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewHabit()
    }
}

struct BottomButton: View {
    
    let text: String
    var withBottomPadding: Bool = true
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.green)
                .frame(height: 50)
                .padding(.horizontal, 15)
            Text(text)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding(.bottom, withBottomPadding ? 10 : 0)
    }
}


struct SkipButton: View {
    var body: some View {
        ZStack {
            Spacer()
                .frame(height: 50)
                .padding(.horizontal, 15)
            Text("Skip")
                .fontWeight(.bold)
                .foregroundColor(.green)
        }
        .padding(.bottom, 10)
    }
}
