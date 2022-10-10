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
}

struct CreateNewTracker: View {
  
  var habit: Habit
  
  let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
  let columnSpacing: CGFloat = 11
  
  var body: some View {
    Background {
      VStack {
        Spacer()
          .frame(height: 50)
        HabitCreationHeader(systemImage: "chart.xyaxis.line",
                            title: "Add a Tracker",
                            subtitle: "Track your progress and visualize your gains to stay motivated")
        
        LazyVGrid(columns: columns, spacing: columnSpacing) {
          
          NavigationLink(value: CreateTrackerNavRoute.graphTracker) {
            TrackerView(systemImage: "chart.xyaxis.line",
                        color: .blue,
                        title: "Graph")
          }
          
          NavigationLink(value: CreateTrackerNavRoute.imageTracker) {
            TrackerView(systemImage: "photo",
                        color: .mint,
                        title: "Photo")
          }
          
          NavigationLink(value: CreateTrackerNavRoute.exerciseTracker) {
            TrackerView(systemImage: "figure.walk",
                        color: .red,
                        title: "Exercise")
          }
          
//          NavigationLink(value: CreateTrackerNavRoute.timeTracker) {
//            TrackerView(systemImage: "timer",
//                        color: .yellow,
//                        title: "Time")
//          }
        }
        .padding(.horizontal, 15)
        
        Spacer()
      }
      .navigationDestination(for: CreateTrackerNavRoute.self) { route in
        switch route {
        case .graphTracker:
          CreateGraphTracker(habit: habit)
        case .imageTracker:
          CreateImageTracker(habit: habit)
        case .exerciseTracker:
          CreateExerciseTracker(habit: habit)
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
    
    NavigationView {
      CreateNewTracker(habit: habit)
    }
  }
}

struct TrackerView: View {
  let systemImage: String
  let color: Color
  let title: String
  var available: Bool = true
  
  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 10)
        .frame(width: 100, height: 100)
        .foregroundColor(.cardColor)
      
      VStack {
        Image(systemName: systemImage)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 35, height: 35)
          .foregroundColor(color)
        Text(title)
        if !available {
          Text("Not available yet")
            .font(.system(size: 9))
        }
      }
    }
  }
}
