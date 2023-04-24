//
//  HabitListViewContainer.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 4/11/23.
//

import SwiftUI

struct IntermediaryHabitListView: View {
   
   @Binding var hideTabBar: Bool
   
   var body: some View {
      let _ = Self._printChanges()
      HabitListView(hideTabBar: $hideTabBar)
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
   @EnvironmentObject var nav: HabitTabNavPath
   @EnvironmentObject var hlvm: HabitListViewModel
   
   @ObservedObject var hwvm = HeaderWeekViewModel()
   
   @State private var hideTabBar = false
   
   var body: some View {
      let _ = Self._printChanges()
      Background {
         VStack {
            IntermediaryHeaderView()
            IntermediaryHabitListView(hideTabBar: $hideTabBar)
         }
         .navigationDestination(for: HabitListViewRoute.self) { route in
            if case let .showProgress(habit) = route {
               HabitProgessView()
                  .environmentObject(nav)
                  .environmentObject(habit)
            }
            if case .createHabit = route {
               CreateHabitName(hideTabBar: $hideTabBar)
                  .environmentObject(nav)
            }
         }
      }
      .environmentObject(hwvm)
      .onAppear {
         hwvm.updateDayToToday()
      }
      .onChange(of: scenePhase) { newPhase in
         if newPhase == .active {
            hwvm.updateDayToToday()
         }
      }
   }
}

struct HabitListViewContainer_Previews: PreviewProvider {
   static var previews: some View {
      HabitListViewContainer()
   }
}
