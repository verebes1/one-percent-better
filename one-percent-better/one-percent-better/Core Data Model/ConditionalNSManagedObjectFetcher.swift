//
//  ConditionalNSManagedObjectFetcher.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 5/11/23.
//

import Foundation
import CoreData

class ConditionalNSManagedObjectFetcher<T: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate, ObservableObject {
   let resultsController: NSFetchedResultsController<T>
   var moc: NSManagedObjectContext
   
   init(_ context: NSManagedObjectContext, entityName: String, sortDescriptors: [NSSortDescriptor] = [], predicate: NSPredicate? = nil) {
      let request = NSFetchRequest<T>(entityName: entityName)
      request.sortDescriptors = sortDescriptors
      request.predicate = predicate
      resultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
      moc = context
      super.init()
      resultsController.delegate = self
      try? resultsController.performFetch()
   }

   func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
      assertionFailure("Override me")
   }
}
