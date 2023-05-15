//
//  HabitListViewContainer.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 4/11/23.
//

import SwiftUI

struct HabitListViewContainer: View {
   
   @Environment(\.scenePhase) var scenePhase
   @EnvironmentObject var hlvm: HabitListViewModel
   @EnvironmentObject var hsvm: HeaderSelectionViewModel
   @EnvironmentObject var barManager: BottomBarManager
   
   var body: some View {
      let _ = Self._printChanges()
      Background {
         VStack {
            HabitsHeaderView()
            HabitListView()
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
      .onAppear {
         hsvm.updateDayToToday()
      }
      .onChange(of: scenePhase) { newPhase in
         if newPhase == .active {
            hsvm.updateDayToToday()
         }
      }
      .navigationTitle(hsvm.navTitle)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
         // Edit Habit List
         if !hlvm.habits.isEmpty {
            ToolbarItem(placement: .navigationBarLeading) {
               EditButton()
            }
         }
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

struct HabitListViewContainer_Previews: PreviewProvider {
   static var previews: some View {
      HabitListViewContainer()
   }
}
