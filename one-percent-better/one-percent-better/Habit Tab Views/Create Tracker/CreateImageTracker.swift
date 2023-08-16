//
//  CreateImageTracker.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/3/22.
//

import SwiftUI

struct CreateImageTracker: View {
    @Environment(\.managedObjectContext) var moc
    
    @EnvironmentObject var nav: HabitTabNavPath
    @EnvironmentObject var barManager: BottomBarManager
    
    var habit: Habit
    @State var trackerName: String = ""
    @FocusState private var nameInFocus: Bool
    
    var body: some View {
        Background {
            VStack {
                HabitCreationHeader(systemImage: "photo",
                                    title: "Photo")
                
                CreateTextField(placeholder: "Name", text: $trackerName, focus: $nameInFocus)
                
                Spacer()
                
                BottomButtonDisabledWhenEmpty(text: "Create", dependingLabel: $trackerName)
                    .onTapGesture {
                        if !trackerName.isEmpty {
                            let _ = ImageTracker(context: moc, habit: habit, name: trackerName)
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

struct CreateImageTracker_Previews: PreviewProvider {
    
    @State static var rootPresenting: Bool = false
    
    static var previews: some View {
        let _ = try? Habit(context: CoreDataManager.previews.mainContext, name: "Swimming")
        let habit = Habit.habits(from: CoreDataManager.previews.mainContext).first!
        CreateImageTracker(habit: habit)
    }
}
