//
//  CreateNewTracker.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/17/22.
//

import SwiftUI

struct CreateNewTracker: View {
    
    let habitName: String
    
    let trackerViews: [TrackerView] = [
        TrackerView(systemImage: "chart.xyaxis.line",
                    color: .blue,
                    title: "Graph"),
        TrackerView(systemImage: "photo",
                    color: .mint,
                    title: "Picture",
                    available: false),
        TrackerView(systemImage: "video",
                    color: .purple,
                    title: "Video",
                    available: false),
        TrackerView(systemImage: "note.text",
                    color: .red,
                    title: "Note",
                    available: false),
        TrackerView(systemImage: "face.smiling",
                    color: .yellow,
                    title: "Feeling",
                    available: false),
        TrackerView(systemImage: "mic",
                    color: .cyan,
                    title: "Audio Note",
                    available: false)
    ]
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    let columnSpacing: CGFloat = 11
    
    var body: some View {
        ZStack {
            Background()
            VStack {
                Spacer()
                    .frame(height: 50)
                HabitCreationHeader(systemImage: "chart.xyaxis.line",
                                    title: "Add a Tracker",
                                    subtitle: "Seeing your progress is one of the most effective forms of motivation")
                
                LazyVGrid(columns: columns, spacing: columnSpacing) {
                    ForEach(trackerViews, id: \.self.title) { trackerView in
                        trackerView
                    }
                }
                .padding(.horizontal, 15)

                Spacer()
//
//                BottomButton(withBottomPadding: false)
//                SkipButton()
            }
        }
    }
}

struct CreateNewTracker_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewTracker(habitName: "Test Habit")
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
                .foregroundColor(.listColor)
            
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
