//
//  CoreDataTransferObject.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 6/30/23.
//

import Foundation
import CoreData

/// Unified way of converting `NSManagedObject` objects to Swift classes and vice versa
protocol CoreDataTransferObject {
   associatedtype ManagedObject: NSManagedObject
   
   var originalManagedObject: ManagedObject? { get }
   
   /// Method to update the managed object
   func updateManagedObject(in context: NSManagedObjectContext) -> ManagedObject
}

//func save<CDTO: CoreDataTransferObject>(_ cdto: CDTO, in context: NSManagedObjectContext) {
//   _ = cdto.updateManagedObject(in: context)
//
//   do {
//      try context.save()
//   } catch {
//      print("Save failed: \(error)")
//   }
//}


//func fetch<CDTO: CoreDataTransferObject>(_ type: CDTO.Type, in context: NSManagedObjectContext) -> [CDTO] {
//   let request = CDTO.ManagedObject.fetchRequest()
//
//   do {
//      let results = try context.fetch(request)
//
//      return results.map(CDTO.init(from:))
//   } catch {
//      print("Fetch failed: \(error)")
//      return []
//   }
//}
