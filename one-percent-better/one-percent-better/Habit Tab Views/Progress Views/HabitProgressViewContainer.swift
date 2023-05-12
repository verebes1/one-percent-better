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

class ProgressViewModel: ConditionalNSManagedObjectFetcher<Habit> {
   @Published var habit: Habit
   var cancelBag = Set<AnyCancellable>()
   
   init(_ context: NSManagedObjectContext = CoreDataManager.shared.mainContext, habit: Habit) {
      self.habit = habit
      super.init(context, entityName: Habit.entity().name!, predicate: NSPredicate(format: "id == %@", habit.id as CVarArg))
      
      $habit
         .sink { habit in
            print("Progress habit: \(habit.name) is changing!")
         }
         .store(in: &cancelBag)
   }
   
   override func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
      guard let newHabits = controller.fetchedObjects as? [Habit] else { return }
      guard !newHabits.isEmpty else { return }
      habit = newHabits.first!
   }
   
   func deleteHabit() {
      // Remove the item to be deleted
      moc.delete(habit)
      
      // Update order indices and save context
      let _ = Habit.habits(from: moc)
   }
}

class TrackersViewModel: ConditionalNSManagedObjectFetcher<Tracker> {
   @Published var trackers: [Tracker]
//   var cancelBag = Set<AnyCancellable>()
   
   init(_ context: NSManagedObjectContext = CoreDataManager.shared.mainContext, habit: Habit) {
      self.trackers = habit.editableTrackers
      super.init(context, entityName: Tracker.entity().name!, predicate: NSPredicate(format: "habit.id == %@ AND autoTracker == false", habit.id as CVarArg))
   }
   
   override func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
      guard let newTrackers = controller.fetchedObjects as? [Tracker] else { return }
      guard !newTrackers.isEmpty else { return }
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
