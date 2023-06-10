//
//  ConditionalManagedObjectFetcher.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 5/11/23.
//

import Foundation
import CoreData

class ConditionalManagedObjectFetcher<T: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate, ObservableObject {
   let resultsController: NSFetchedResultsController<T>
   var moc: NSManagedObjectContext
   
   init(_ context: NSManagedObjectContext, sortDescriptors: [NSSortDescriptor] = [], predicate: NSPredicate? = nil) {
      let request = NSFetchRequest<T>(entityName: T.entity().name!)
      request.sortDescriptors = sortDescriptors
      request.predicate = predicate
      resultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
      moc = context
      super.init()
      resultsController.delegate = self
      try? resultsController.performFetch()
   }
   
   var fetchedObjects: [T] {
      resultsController.fetchedObjects ?? []
   }

   func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
      assertionFailure("Override me")
   }
}