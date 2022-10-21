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
  
  var habit: Habit
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
          }
          .padding(.horizontal, 20)
        }
        
        Spacer()
        
        BottomButtonDisabledWhenEmpty(text: "Create", dependingLabel: $trackerName)
          .onTapGesture {
            if !trackerName.isEmpty {
              let _ = NumberTracker(context: moc, habit: habit, name: trackerName)
              moc.fatalSave()
              nav.path.removeLast(2)
            }
          }
        
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
