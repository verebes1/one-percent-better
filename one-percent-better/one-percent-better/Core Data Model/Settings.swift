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
   @NSManaged public var dailyReminderEnabled: Bool
   @NSManaged public var dailyReminderTime: Date
   
   convenience init(myContext: NSManagedObjectContext) {
      self.init(context: myContext)
      self.dailyReminderEnabled = false
      self.dailyReminderTime = Cal.date(from: DateComponents(hour: 21))!
   }
}

// MARK: Fetch Request

extension Settings: HasFetchRequest {
   public class func fetchRequest<Settings>() -> NSFetchRequest<Settings> {
      return NSFetchRequest<Settings>(entityName: "Settings")
   }
}
