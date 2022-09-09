//
//  CreateExerciseTracker.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 9/9/22.
//

import SwiftUI

struct CreateExerciseTracker: View {
    @Environment(\.managedObjectContext) var moc
    
    var habit: Habit
    @Binding var progressPresenting: Bool
    @State var trackerName: String = ""

    var body: some View {
        Background {
            VStack {
                HabitCreationHeader(systemImage: "figure.walk",
                                    title: "Exercise")
                
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.cardColor)
                            .frame(height: 40)
                        TextField("Name", text: $trackerName)
                            .padding(.leading, 10)
                    }.padding(.horizontal, 20)
                }
                
                Spacer()
                
                BottomButtonDisabledWhenEmpty(text: "Create", dependingLabel: $trackerName)
                    .onTapGesture {
                        if !trackerName.isEmpty {
                            let _ = ExerciseTracker(context: moc, habit: habit, name: trackerName)
                            moc.fatalSave()
                            progressPresenting = false
                        }
                    }
                
            }
        }
    }
}

struct CreateExerciseTracker_Previews: PreviewProvider {
    
    @State static var rootPresenting: Bool = false
    
    static var previews: some View {
        let habit = PreviewData.sampleHabit()
        CreateExerciseTracker(habit: habit, progressPresenting: $rootPresenting)
    }
}
