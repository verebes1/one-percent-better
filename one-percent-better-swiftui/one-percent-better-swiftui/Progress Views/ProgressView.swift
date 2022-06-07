//
//  ProgressView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/18/22.
//

import SwiftUI
import CoreData

class ProgressViewModel: ObservableObject {
    
    var habit: Habit
    var trackers: [Tracker]
    
    init(habit: Habit) {
        self.habit = habit
        self.trackers = habit.trackers.map{ $0 as! Tracker }
    }
}

struct ProgressView: View {
    
    var vm: ProgressViewModel
    
    @State var progressPresenting: Bool = false
    
    var body: some View {
        Background {
            VStack(spacing: 20) {
                CardView {
                    CalendarView()
                }
                
                ForEach(vm.trackers) { tracker in
                    CardView {
                        Text(tracker.name)
                    }
                }
                
                NavigationLink(destination: CreateTableTracker(habit: vm.habit, progressPresenting: $progressPresenting),
                               isActive: $progressPresenting) {
                    Label("New Tracker", systemImage: "plus.circle")
                }
                .isDetailLink(false)
                .padding(.top, 15)
                
                Spacer()
            }
            .navigationTitle(vm.habit.name)
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct ProgressView_Previews: PreviewProvider {
    
    static var previews: some View {
        let habit = PreviewData.progressViewData()
        let vm = ProgressViewModel(habit: habit)
        return(
            NavigationView {
                ProgressView(vm: vm)
                    .preferredColorScheme(.light)
                    .environmentObject(habit)
            }
        )
    }
}
