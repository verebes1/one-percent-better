//
//  HabitObserver.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/25/22.
//

//import Foundation
//import CoreData
//
//class HabitObserver: NSObject, NSFetchedResultsControllerDelegate {
//   
//   let habitController: NSFetchedResultsController<Habit>
//   let moc: NSManagedObjectContext
//   
//   init(_ context: NSManagedObjectContext, predicate: NSPredicate? = nil) {
//      let sortDescriptors = [NSSortDescriptor(keyPath: \Habit.orderIndex, ascending: true)]
//      habitController = Habit.resultsController(context: context, sortDescriptors: sortDescriptors, predicate: predicate)
//      moc = context
//      super.init()
//      habitController.delegate = self
//      try? habitController.performFetch()
//   }
//   
//   var results: [Habit] {
//      return habitController.fetchedObjects ?? []
//   }
//   
//   var firstResult: Habit? {
//      let results = habitController.fetchedObjects ?? []
//      if results.isEmpty {
//         return nil
//      } else {
//         return results[0]
//      }
//   }
   
   //   func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
   //      objectWillChange.send()
   //   }
//}
