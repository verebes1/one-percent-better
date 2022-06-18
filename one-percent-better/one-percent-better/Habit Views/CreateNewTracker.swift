//
//  CreateNewTracker.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/17/22.
//

import SwiftUI

struct CreateNewTracker: View {
    
    var habit: Habit
    
    @Binding var progressPresenting: Bool
    
    let trackerViews: [TrackerView] = [
//        TrackerView(systemImage: "tablecells",
//                    color: .systemOrange,
//                    title: "Table"),
        TrackerView(systemImage: "chart.xyaxis.line",
                    color: .blue,
                    title: "Graph"),
        TrackerView(systemImage: "photo",
                    color: .mint,
                    title: "Photo")
//        TrackerView(systemImage: "video",
//                    color: .purple,
//                    title: "Video",
//                    available: false),
//        TrackerView(systemImage: "note.text",
//                    color: .red,
//                    title: "Note",
//                    available: false),
//        TrackerView(systemImage: "face.smiling",
//                    color: .yellow,
//                    title: "Feeling",
//                    available: false),
//        TrackerView(systemImage: "mic",
//                    color: .cyan,
//                    title: "Recording",
//                    available: false)
    ]
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    let columnSpacing: CGFloat = 11
    
    var body: some View {
        Background {
            VStack {
                Spacer()
                    .frame(height: 50)
                HabitCreationHeader(systemImage: "chart.xyaxis.line",
                                    title: "Add a Tracker",
                                    subtitle: "Seeing your progress is one of the most effective forms of motivation")
                
                LazyVGrid(columns: columns, spacing: columnSpacing) {
                    
                    NavigationLink(destination: CreateGraphTracker(habit: habit, progressPresenting: $progressPresenting)) {
                        TrackerView(systemImage: "chart.xyaxis.line",
                                    color: .blue,
                                    title: "Graph")
                    }
                    .isDetailLink(false)
                    
                    NavigationLink(destination: CreateImageTracker(habit: habit, progressPresenting: $progressPresenting)) {
                        TrackerView(systemImage: "photo",
                                    color: .mint,
                                    title: "Photo")
                    }
                    .isDetailLink(false)
                }
                .padding(.horizontal, 15)

                Spacer()
            }
        }
    }
}

struct CreateNewTracker_Previews: PreviewProvider {
    
    @State static var parentPresenting: Bool = false
    
    static var previews: some View {
        let habit = PreviewData.sampleHabit()
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
