//
//  ProgressView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/18/22.
//

import SwiftUI
import CoreData

struct ProgressView: View {
    
    @EnvironmentObject var habit: Habit
    
    @State var progressPresenting: Bool = false
    
    var body: some View {
        Background {
            VStack(spacing: 20) {
                CardView {
                    CalendarView()
                }
                
                NavigationLink(destination: CreateNewTracker(progressPresenting: $progressPresenting), isActive: $progressPresenting) {
                    Label("New Tracker", systemImage: "plus.circle")
                }
                .padding(.top, 15)
                
                
                Spacer()
            }
            .navigationTitle(habit.name)
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct ProgressView_Previews: PreviewProvider {
    
    static var previews: some View {
        let habit = PreviewData.progressViewData()
        return(
            NavigationView {
                ProgressView()
                    .preferredColorScheme(.light)
                    .environmentObject(habit)
            }
                
        )
    }
}
