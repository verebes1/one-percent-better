//
//  CreateGraphTracker.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 6/17/22.
//

import SwiftUI

struct CreateGraphTracker: View {
    @Environment(\.managedObjectContext) var moc
    
    var habit: Habit
    @Binding var progressPresenting: Bool
    @State var trackerName: String = ""

    var body: some View {
        Background {
            VStack {
                HabitCreationHeader(systemImage: "chart.xyaxis.line",
                                    title: "Graph")
                
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
                            let _ = NumberTracker(context: moc, habit: habit, name: trackerName)
                            moc.fatalSave()
                            progressPresenting = false
                        }
                    }
                
            }
        }
    }
}

struct CreateGraphTracker_Previews: PreviewProvider {
    
    @State static var rootPresenting: Bool = false
    
    static var previews: some View {
        let _ = try? Habit(context: CoreDataManager.previews.mainContext, name: "Swimming")
                let habit = Habit.habits(from: CoreDataManager.previews.mainContext).first!
        CreateGraphTracker(habit: habit, progressPresenting: $rootPresenting)
    }
}
