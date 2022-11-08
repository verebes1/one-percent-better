//
//  CreateNewTracker.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/17/22.
//

import SwiftUI

enum CreateTrackerNavRoute: Hashable {
   case graphTracker
   case imageTracker
   case exerciseTracker
   case timeTracker
}

struct CreateNewTracker: View {
   
   @EnvironmentObject var nav: HabitTabNavPath
   
   var habit: Habit
   
   let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 20), count: 3)
   let columnSpacing: CGFloat = 20
   
   var body: some View {
      Background {
         VStack {
            Spacer()
               .frame(height: 50)
            HabitCreationHeader(systemImage: "chart.xyaxis.line",
                                title: "Add a Tracker",
                                subtitle: "Track your progress and visualize your gains to stay motivated")
            
            
            LazyVGrid(columns: columns, spacing: columnSpacing) {
               
               CreateTrackerButton(systemImage: "chart.xyaxis.line",
                                   color: .blue,
                                   title: "Graph",
                                   navPath: CreateTrackerNavRoute.graphTracker)
               
               CreateTrackerButton(systemImage: "photo",
                                   color: .mint,
                                   title: "Photo",
                                   navPath: CreateTrackerNavRoute.imageTracker)
               
               CreateTrackerButton(systemImage: "figure.walk",
                                   color: .red,
                                   title: "Exercise",
                                   navPath: CreateTrackerNavRoute.exerciseTracker)
               
               CreateTrackerButton(systemImage: "timer",
                                   color: .yellow,
                                   title: "Time",
                                   available: false,
                                   navPath: CreateTrackerNavRoute.timeTracker)
               
               CreateTrackerButton(systemImage: "note.text",
                                   color: .systemOrange,
                                   title: "Notes",
                                   available: false,
                                   navPath: CreateTrackerNavRoute.timeTracker)
               
            }
            .padding(.horizontal, columnSpacing)
            
            Spacer()
         }
         .navigationDestination(for: CreateTrackerNavRoute.self) { route in
            switch route {
            case .graphTracker:
               CreateGraphTracker(habit: habit)
                  .environmentObject(nav)
            case .imageTracker:
               CreateImageTracker(habit: habit)
                  .environmentObject(nav)
            case .exerciseTracker:
               CreateExerciseTracker(habit: habit)
                  .environmentObject(nav)
            case .timeTracker:
               CreateTimeTracker(habit: habit)
                  .environmentObject(nav)
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

struct CreateTrackerButton: View {
   
   @EnvironmentObject var nav: HabitTabNavPath
   
   let systemImage: String
   let color: Color
   let title: String
   var available: Bool = true
   let navPath: CreateTrackerNavRoute
   
   var body: some View {
      Button {
         if available {
            nav.path.append(navPath)
         }
      } label: {
         VStack {
            Image(systemName: systemImage)
               .resizable()
               .aspectRatio(contentMode: .fit)
               .frame(width: 35, height: 35)
               .shadow(color: .black.opacity(0.2), radius: 3, x: 3, y: 3)
            
            Text(title)
               .font(.system(size: 14))
               .fontWeight(.bold)
               .shadow(color: .black.opacity(0.2), radius: 3, x: 3, y: 3)
            
            if !available {
               Text("Coming Soon")
                  .font(.system(size: 8))
                  .shadow(color: .black.opacity(0.2), radius: 3, x: 3, y: 3)
            }
         }
         .frame(maxWidth: .infinity, maxHeight: .infinity)
         .aspectRatio(1.0, contentMode: .fill)
      }
      .buttonStyle(RoundedRectButtonStyle(cornerRadius: 20,
                                          color: color))
   }
}
