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
   
   static func data() {
      let context = CoreDataManager.previews.mainContext
      
      let _ = try? Habit(context: context, name: "Never completed", id: HabitsViewPreviewer.h0id)
      
      let h1 = try? Habit(context: context, name: "Completed yesterday", id: HabitsViewPreviewer.h1id)
      let yesterday = Cal.date(byAdding: .day, value: -1, to: Date())!
      h1?.markCompleted(on: yesterday)
      
      let h2 = try? Habit(context: context, name: "Completed today", id: HabitsViewPreviewer.h2id)
      h2?.markCompleted(on: Date())
   }
   
   static var previews: some View {
      data()
      return (
         NavigationStack {
            HabitListViewContainer()
               .environmentObject(HabitListViewModel(CoreDataManager.previews.mainContext))
               .environmentObject(HeaderSelectionViewModel(hwvm: HeaderWeekViewModel(CoreDataManager.previews.mainContext)))
               .environmentObject(BottomBarManager())
               .environment(\.managedObjectContext, CoreDataManager.previews.mainContext)
         }
      )
   }
}
