//
//  CreateExerciseTracker.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 9/9/22.
//

import SwiftUI

struct CreateExerciseTracker: View {
   @Environment(\.managedObjectContext) var moc
   
   @EnvironmentObject var nav: HabitTabNavPath
   
   var habit: Habit
   @State var trackerName: String = ""
   @FocusState private var nameInFocus: Bool
   
   var body: some View {
      Background {
         VStack {
            HabitCreationHeader(systemImage: "figure.walk",
                                title: "Exercise")
            
            CreateTextField(placeholder: "Name", text: $trackerName, focus: $nameInFocus)
            
            Spacer()
            
            BottomButtonDisabledWhenEmpty(text: "Create", dependingLabel: $trackerName)
               .onTapGesture {
                  if !trackerName.isEmpty {
                     let _ = ExerciseTracker(context: moc, habit: habit, name: trackerName)
                     moc.assertSave()
                     nav.path.removeLast(2)
                  }
               }
         }
         .onAppear {
            nameInFocus = true
         }
      }
   }
}

struct CreateExerciseTracker_Previews: PreviewProvider {
   
   @State static var rootPresenting: Bool = false
   
   static var previews: some View {
      let _ = try? Habit(context: CoreDataManager.previews.mainContext, name: "Swimming")
      let habit = Habit.habits(from: CoreDataManager.previews.mainContext).first!
      CreateExerciseTracker(habit: habit)
   }
}
