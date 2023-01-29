//
//  CreateNewTracker.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/17/22.
//

import SwiftUI

enum CreateTrackerNavRoute: Hashable {
   case graphTracker(Habit)
   case imageTracker(Habit)
   case exerciseTracker(Habit)
   case timeTracker(Habit)
   case noteTracker(Habit)
}

struct TrackerListItem: Hashable {
   let title: String
   let description: String
   let systemImage: String
   let color: Color
}

struct CreateNewTracker: View {
   
   @EnvironmentObject var nav: HabitTabNavPath
   
   var habit: Habit
   
   let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 20), count: 3)
   let columnSpacing: CGFloat = 20
   
   let graphTrackerItem = TrackerListItem(title: "Graph",
                      description: "Track a number which changes over time, like body weight.",
                      systemImage: "chart.xyaxis.line",
                      color: .blue)
   let photoTrackerItem = TrackerListItem(title: "Photo",
                      description: "Track visual progress using a photo, such as a plant growing over time.",
                      systemImage: "photo",
                      color: .mint)
   
   let exerciseTrackerItem = TrackerListItem(title: "Exercise",
                      description: "Track the sets of weights and reps you do at the gym.",
                      systemImage: "figure.walk",
                      color: .red)
   
   let timeTrackerItem = TrackerListItem(title: "Time (Coming Soon)",
                      description: "Track the time you spend on this habit.",
                      systemImage: "timer",
                      color: .yellow)
   
   let noteTrackerItem = TrackerListItem(title: "Note (Coming Soon)",
                      description: "Take custom notes to track progress for this habit.",
                      systemImage: "note.text",
                      color: .systemOrange)
   
   var body: some View {
      Background {
         VStack {
            HabitCreationHeader(systemImage: "chart.xyaxis.line",
                                title: "Add a Tracker",
                                subtitle: "Track your progress and visualize your gains to stay motivated")
            
            List {
               NavigationLink(value: CreateTrackerNavRoute.graphTracker(habit)) {
                  CreateTrackerListItem(tracker: graphTrackerItem)
               }
               
               NavigationLink(value: CreateTrackerNavRoute.imageTracker(habit)) {
                  CreateTrackerListItem(tracker: photoTrackerItem)
               }
               
               NavigationLink(value: CreateTrackerNavRoute.exerciseTracker(habit)) {
                  CreateTrackerListItem(tracker: exerciseTrackerItem)
               }
               
//               NavigationLink(value: CreateTrackerNavRoute.timeTracker(habit)) {
                  CreateTrackerListItem(tracker: timeTrackerItem)
//               }
               
//               NavigationLink(value: CreateTrackerNavRoute.noteTracker(habit)) {
                  CreateTrackerListItem(tracker: noteTrackerItem)
//               }
            }
            
         }
         .navigationDestination(for: CreateTrackerNavRoute.self) { [nav] route in
            switch route {
            case .graphTracker(let habit):
               CreateGraphTracker(habit: habit)
                  .environmentObject(nav)
            case .imageTracker(let habit):
               CreateImageTracker(habit: habit)
                  .environmentObject(nav)
            case .exerciseTracker(let habit):
               CreateExerciseTracker(habit: habit)
                  .environmentObject(nav)
            case .timeTracker(let habit):
               CreateTimeTracker(habit: habit)
                  .environmentObject(nav)
            case .noteTracker(_):
               // TODO
               EmptyView()
            }
         }
      }
   }
}

struct CreateNewTracker_Previews: PreviewProvider {
   
   @State static var parentPresenting: Bool = false
   
   static var previews: some View {
      let _ = try? Habit(context: CoreDataManager.previews.mainContext, name: "Swimming")
      let habit = Habit.habits(from: CoreDataManager.previews.mainContext).first!
      
      NavigationStack {
         CreateNewTracker(habit: habit)
            .environmentObject(HabitTabNavPath())
      }
   }
}

struct CreateTrackerListItem: View {
   
   let tracker: TrackerListItem
   
   var body: some View {
      HStack(alignment: .top) {
         Image(systemName: tracker.systemImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 18, height: 18)
            .foregroundColor(.white)
            .padding(7)
            .background(tracker.color)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .padding(5)
         
         VStack(alignment: .leading, spacing: 4) {
            Text(tracker.title)
               .fontWeight(.medium)
            
            Text(tracker.description)
               .foregroundColor(.secondaryLabel)
               .font(.system(size: 14))
         }
      }
      .padding(.vertical, 5)
   }
}
