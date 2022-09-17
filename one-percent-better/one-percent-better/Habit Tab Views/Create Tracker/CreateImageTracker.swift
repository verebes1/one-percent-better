//
//  CreateImageTracker.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/3/22.
//

import SwiftUI

struct CreateImageTracker: View {
    @Environment(\.managedObjectContext) var moc
    
    var habit: Habit
    @Binding var progressPresenting: Bool
    @State var trackerName: String = ""

    var body: some View {
        Background {
            VStack {
                HabitCreationHeader(systemImage: "photo",
                                    title: "Photo")
                
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.cardColor)
                            .frame(height: 50)
                        TextField("Name", text: $trackerName)
                            .padding(.leading, 10)
                    }.padding(.horizontal, 20)
                }
                
                Spacer()
                
                BottomButtonDisabledWhenEmpty(text: "Create", dependingLabel: $trackerName)
                    .onTapGesture {
                        if !trackerName.isEmpty {
                            let _ = ImageTracker(context: moc, habit: habit, name: trackerName)
                            moc.fatalSave()
                            progressPresenting = false
                        }
                    }
                
            }
        }
    }
}

struct CreateImageTracker_Previews: PreviewProvider {
    
    @State static var rootPresenting: Bool = false
    
    static var previews: some View {
        let _ = try? Habit(context: CoreDataManager.previews.mainContext, name: "Swimming")
        let habit = Habit.habits(from: CoreDataManager.previews.mainContext).first!
        CreateImageTracker(habit: habit, progressPresenting: $rootPresenting)
    }
}
