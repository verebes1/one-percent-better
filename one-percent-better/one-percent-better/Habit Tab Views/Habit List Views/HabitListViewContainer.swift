//
//  HabitListViewContainer.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 4/11/23.
//

import SwiftUI

struct HabitListViewContainer: View {
    
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var barManager: BottomBarManager
    @StateObject var hwvm: HeaderWeekViewModel
    @StateObject var sdvm: SelectedDateViewModel
    
    init() {
        let hwvm = HeaderWeekViewModel()
        let sdvm = SelectedDateViewModel(hwvm: hwvm)
        self._hwvm = StateObject(wrappedValue: hwvm)
        self._sdvm = StateObject(wrappedValue: sdvm)
    }
    
    var body: some View {
        let _ = Self._printChanges()
        Background {
            VStack(spacing: 5) {
                HabitsHeaderView()
                    .environmentObject(hwvm)
                    .environmentObject(sdvm)
                
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
        .onAppear {
            sdvm.updateSelectedDayToToday()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                sdvm.updateSelectedDayToToday()
            }
        }
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
