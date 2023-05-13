//
//  HabitProgressViewContainer.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 5/7/23.
//

import SwiftUI
import CoreData
import Combine

enum ProgressViewNavRoute: Hashable {
   case editHabit
   case newTracker
}

class ProgressViewModel: ConditionalManagedObjectFetcher<Habit> {
   @Published var habit: Habit
   
   init(_ context: NSManagedObjectContext = CoreDataManager.shared.mainContext, habit: Habit) {
      self.habit = habit
      super.init(context, predicate: NSPredicate(format: "id == %@", habit.id as CVarArg))
   }
   
   override func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
      guard let newHabits = controller.fetchedObjects as? [Habit] else { return }
      guard !newHabits.isEmpty else { return }
      habit = newHabits.first!
   }
   
   func deleteHabit() {
      moc.delete(habit)
      // Update order indices and save context
      let _ = Habit.habits(from: moc)
   }
}

class TrackersViewModel: ConditionalManagedObjectFetcher<Tracker> {
   @Published var trackers: [Tracker]
   
   init(_ context: NSManagedObjectContext = CoreDataManager.shared.mainContext, habit: Habit) {
      self.trackers = habit.editableTrackers
      super.init(context, predicate: NSPredicate(format: "habit.id == %@ AND autoTracker == false", habit.id as CVarArg))
   }
   
   override func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
      guard let newTrackers = controller.fetchedObjects as? [Tracker] else { return }
      trackers = newTrackers
   }
}

struct HabitProgressViewContainer: View {
   
   @StateObject var vm: ProgressViewModel
   @StateObject var tm: TrackersViewModel
   
   init(habit: Habit) {
      print("~~~~ HabitProgressViewContainer init")
      self._vm = StateObject(wrappedValue: ProgressViewModel(habit: habit))
      self._tm = StateObject(wrappedValue: TrackersViewModel(habit: habit))
   }
   
   var body: some View {
      let _ = Self._printChanges()
      Background {
         HabitProgessView()
            .environmentObject(vm)
            .navigationTitle(vm.habit.name)
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: ProgressViewNavRoute.self) { route in
               if case .editHabit = route {
                  EditHabit(habit: vm.habit)
                     .environmentObject(vm)
                     .environmentObject(tm)
               }
               
               if case .newTracker = route {
                  CreateNewTracker(habit: vm.habit)
               }
            }
      }
      .toolbar {
         ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
               NavigationLink(value: ProgressViewNavRoute.editHabit) {
                  Label("Edit Habit", systemImage: "pencil")
               }
               NavigationLink(value: ProgressViewNavRoute.newTracker) {
                  Label("New Tracker", systemImage: "plus")
               }
            } label: {
               Image(systemName: "ellipsis.circle")
            }
         }
      }
   }
}

//
//struct HabitProgressViewContainer_Previews: PreviewProvider {
//    static var previews: some View {
//        HabitProgressViewContainer()
//    }
//}
