//
//  CreateTableTracker.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/3/22.
//

import SwiftUI

struct CreateTableTracker: View {
    @Environment(\.managedObjectContext) var moc
    
    var habit: Habit
    @Binding var progressPresenting: Bool
    @State var trackerName: String = ""

    var body: some View {
        Background {
            VStack {
                HabitCreationHeader(systemImage: "tablecells",
                                    title: "Table")
                
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
                
                BottomButtonEmptyMeansDisabled(text: "Create", dependingLabel: $trackerName)
                    .onTapGesture {
                        if !trackerName.isEmpty {
                            let _ = NumberTracker(context: moc, habit: habit, name: trackerName)
                            try? moc.save()
                            progressPresenting = false
                        }
                    }
                
            }
        }
    }
}

struct CreateTableTracker_Previews: PreviewProvider {
    
    @State static var rootPresenting: Bool = false
    
    static var previews: some View {
        let habit = PreviewData.sampleHabit()
        CreateTableTracker(habit: habit, progressPresenting: $rootPresenting)
    }
}
