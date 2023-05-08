//
//  HabitProgressViewContainer.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 5/7/23.
//

import SwiftUI
import CoreData

enum ProgressViewNavRoute: Hashable {
   case editHabit(Habit)
   case newTracker(Habit)
}

class ProgressViewModel: HabitConditionalFetcher {
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
}

struct HabitProgressViewContainer: View {
   
   @EnvironmentObject var nav: HabitTabNavPath
   @ObservedObject var vm: ProgressViewModel
   
   init(habit: Habit) {
      print("~~~~ HabitProgressViewContainer init")
      self._vm = ObservedObject(initialValue: ProgressViewModel(habit: habit))
   }
   
   var body: some View {
      let _ = Self._printChanges()
      Background {
         HabitProgessView()
            .environmentObject(vm)
            .navigationTitle(vm.habit.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
               ToolbarItem(placement: .navigationBarTrailing) {
                  Menu {
                     NavigationLink(value: ProgressViewNavRoute.editHabit(vm.habit)) {
                        Label("Edit Habit", systemImage: "pencil")
                     }
                     NavigationLink(value: ProgressViewNavRoute.newTracker(vm.habit)) {
                        Label("New Tracker", systemImage: "plus")
                     }
                  } label: {
                     Image(systemName: "ellipsis.circle")
                  }
               }
            }
            .navigationDestination(for: ProgressViewNavRoute.self) { route in
               if case .editHabit(let habit) = route {
                  EditHabit(habit: habit)
                     .environmentObject(vm)
                     .environmentObject(nav)
               }
               
               if case .newTracker(let habit) = route {
                  CreateNewTracker(habit: habit)
                     .environmentObject(nav)
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
