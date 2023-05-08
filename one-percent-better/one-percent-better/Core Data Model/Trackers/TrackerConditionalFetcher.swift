//
//  TrackerConditionalFetcher.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 5/7/23.
//

import Foundation
import CoreData

class TrackerConditionalFetcher: NSObject, NSFetchedResultsControllerDelegate, ObservableObject {
   let trackerController: NSFetchedResultsController<Tracker>
   var moc: NSManagedObjectContext
   
   init(_ context: NSManagedObjectContext, predicate: NSPredicate? = nil) {
      let request = NSFetchRequest<Tracker>(entityName: "Tracker")
      request.predicate = predicate
      request.sortDescriptors = []
      trackerController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
      moc = context
      super.init()
      trackerController.delegate = self
      try? trackerController.performFetch()
   }

   func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
      assertionFailure("Override me")
   }
}
