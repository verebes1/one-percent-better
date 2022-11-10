//
//  Settings+CoreDataClass.swift
//  
//
//  Created by Jeremy Cook on 10/19/22.
//
//

import Foundation
import CoreData

@objc(Settings)
public class Settings: NSManagedObject {
   
   @nonobjc public class func fetchRequest() -> NSFetchRequest<Settings> {
       return NSFetchRequest<Settings>(entityName: "Settings")
   }

   @NSManaged public var dailyReminderEnabled: Bool
   @NSManaged public var dailyReminderTime: Date
   
   convenience init(myContext: NSManagedObjectContext) {
      self.init(context: myContext)
      self.dailyReminderEnabled = false
      self.dailyReminderTime = Cal.date(from: DateComponents(hour: 21))!
   }
}

extension Settings {
   static func resultsController(context: NSManagedObjectContext, sortDescriptors: [NSSortDescriptor] = []) -> NSFetchedResultsController<Settings> {
      let request = NSFetchRequest<Settings>(entityName: "Settings")
      request.sortDescriptors = []//sortDescriptors.isEmpty ? nil : sortDescriptors
      return NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
   }
}
