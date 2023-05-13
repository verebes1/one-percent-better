//
//  HabitListViewContainer.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 4/11/23.
//

import SwiftUI

struct IntermediaryHabitListView: View {
   var body: some View {
      let _ = Self._printChanges()
      HabitListView()
   }
}


struct IntermediaryHeaderView: View {
   var body: some View {
      let _ = Self._printChanges()
      HabitsHeaderView()
   }
}

struct HabitListViewContainer: View {
   
   @Environment(\.scenePhase) var scenePhase
   @EnvironmentObject var hlvm: HabitListViewModel
   @EnvironmentObject var hsvm: HeaderSelectionViewModel
   @EnvironmentObject var barManager: BottomBarManager
   
   var body: some View {
      let _ = Self._printChanges()
      Background {
         VStack {
            IntermediaryHeaderView()
            IntermediaryHabitListView()
         }
         .navigationDestination(for: HabitListViewRoute.self) { route in
            if case let .showProgress(habit) = route {
               HabitProgressViewContainer(habit: habit)
            }
            if case .createHabit = route {
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
