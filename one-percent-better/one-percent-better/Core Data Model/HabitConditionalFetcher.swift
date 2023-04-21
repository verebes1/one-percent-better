//
//  HabitConditionalFetcher.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 4/11/23.
//

import Foundation
import CoreData

class HabitConditionalFetcher: NSObject, NSFetchedResultsControllerDelegate, ObservableObject {
   let habitController: NSFetchedResultsController<Habit>
   var moc: NSManagedObjectContext
   
   init(_ context: NSManagedObjectContext, predicate: NSPredicate? = nil) {
      let request = NSFetchRequest<Habit>(entityName: "Habit")
      request.predicate = predicate
      request.sortDescriptors = [NSSortDescriptor(keyPath: \Habit.orderIndex, ascending: true)]
      habitController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
      moc = context
      super.init()
      habitController.delegate = self
      try? habitController.performFetch()
   }

   func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
      assertionFailure("Override me")
   }
}

class HabitFetcher: HabitConditionalFetcher {
   
   @Published var habits: [Habit] = []
   
   init(_ context: NSManagedObjectContext) {
      super.init(context)
      habits = habitController.fetchedObjects ?? []
   }
   
   override func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
      guard let newHabits = controller.fetchedObjects as? [Habit] else { return }
      habits = newHabits
   }
}
