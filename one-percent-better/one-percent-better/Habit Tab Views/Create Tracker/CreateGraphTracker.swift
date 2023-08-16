//
//  CreateGraphTracker.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 6/17/22.
//

import SwiftUI

struct CreateGraphTracker: View {
    @Environment(\.managedObjectContext) var moc
    
    @EnvironmentObject var nav: HabitTabNavPath
    @EnvironmentObject var barManager: BottomBarManager
    
    var habit: Habit
    @State var trackerName: String = ""
    @FocusState private var nameInFocus: Bool
    
    var body: some View {
        Background {
            VStack {
                HabitCreationHeader(systemImage: "chart.xyaxis.line",
                                    title: "Graph")
                
                CreateTextField(placeholder: "Name", text: $trackerName, focus: $nameInFocus)
                
                Spacer()
                
                BottomButtonDisabledWhenEmpty(text: "Create", dependingLabel: $trackerName)
                    .onTapGesture {
                        if !trackerName.isEmpty {
                            let _ = NumberTracker(context: moc, habit: habit, name: trackerName)
                            moc.assertSave()
                            nav.path.removeLast(2)
                        }
                    }
                
            }
            .onAppear {
                nameInFocus = true
                barManager.isHidden = true
            }
            .onDisappear {
                barManager.isHidden = false
            }
        }
    }
}

struct CreateGraphTrackerPreviewer: View {
    var body: some View {
        let _ = try? Habit(context: CoreDataManager.previews.mainContext, name: "Swimming")
        let habit = Habit.habits(from: CoreDataManager.previews.mainContext).first!
        CreateGraphTracker(habit: habit)
    }
}

struct CreateGraphTracker_Previews: PreviewProvider {
    static var previews: some View {
        CreateGraphTrackerPreviewer()
    }
}
