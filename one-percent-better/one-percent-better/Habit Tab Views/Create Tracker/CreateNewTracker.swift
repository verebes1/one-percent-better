//
//  CreateNewTracker.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/17/22.
//

import SwiftUI

struct CreateNewTracker: View {
  
  var habit: Habit
  
  @State var path = NavigationPath()
  
  @Binding var progressPresenting: Bool
  
  let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
  let columnSpacing: CGFloat = 11
  
  var body: some View {
    Background {
      NavigationStack(path: $path) {
        VStack {
          Spacer()
            .frame(height: 50)
          HabitCreationHeader(systemImage: "chart.xyaxis.line",
                              title: "Add a Tracker",
                              subtitle: "Track your progress and visualize your gains to stay motivated")
          
          LazyVGrid(columns: columns, spacing: columnSpacing) {
            
            
            NavigationLink(value: "graph") {
              TrackerView(systemImage: "chart.xyaxis.line",
                          color: .blue,
                          title: "Graph")
            }
            
//            NavigationLink {
//              CreateGraphTracker(habit: habit, path: $path)
//            } label: {
//              TrackerView(systemImage: "chart.xyaxis.line",
//                          color: .blue,
//                          title: "Graph")
//            }
//
//            Button {
//              path.append("create_graph")
//            } label: {
//              TrackerView(systemImage: "chart.xyaxis.line",
//                          color: .blue,
//                          title: "Graph")
//            }
            
            NavigationLink(destination: CreateImageTracker(habit: habit, progressPresenting: $progressPresenting)) {
              TrackerView(systemImage: "photo",
                          color: .mint,
                          title: "Photo")
            }
            .isDetailLink(false)
            
//            NavigationLink(destination: CreateTimeTracker(habit: habit, progressPresenting: $progressPresenting)) {
//              TrackerView(systemImage: "timer",
//                          color: .yellow,
//                          title: "Time")
//            }
//            .isDetailLink(false)
            
            NavigationLink(destination: CreateExerciseTracker(habit: habit, progressPresenting: $progressPresenting)) {
              TrackerView(systemImage: "figure.walk",
                          color: .red,
                          title: "Exercise")
            }
            .isDetailLink(false)
          }
          .padding(.horizontal, 15)
          
          Spacer()
        }
        .navigationDestination(for: String.self) { id in
          CreateGraphTracker(habit: habit, path: $path)
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
      CreateNewTracker(habit: habit, progressPresenting: $parentPresenting)
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
