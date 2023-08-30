//
//  HabitListViewContainer.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 4/11/23.
//

import SwiftUI

struct HabitListViewContainer: View {
    
    @EnvironmentObject var barManager: BottomBarManager
    @StateObject var sdvm = SelectedDateViewModel()
    
    var body: some View {
        Background {
            VStack(spacing: 5) {
                HabitsHeaderView(sdvm: sdvm)
                HabitListView(sdvm: sdvm)
            }
            .navigationDestination(for: HabitListViewRoute.self) { route in
                switch route {
                case let .showProgress(habit):
                    HabitProgressViewContainer(habit: habit)
                case .createHabit:
                    CreateHabitName()
                }
            }
        }
        .environmentObject(sdvm)
        .navigationTitle(sdvm.navTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // New Habit
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(value: HabitListViewRoute.createHabit) {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
        .toolbarBackground(Color.backgroundColor, for: .tabBar)
        .toolbar(barManager.isHidden ? .hidden : .visible, for: .tabBar)
    }
}

//struct HabitListViewContainer_Previews: PreviewProvider {
//   static var previews: some View {
//      HabitListViewContainer()
//   }
//}
