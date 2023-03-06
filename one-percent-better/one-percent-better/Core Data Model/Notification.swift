//
//  Notification.swift
//  
//
//  Created by Jeremy Cook on 3/5/23.
//
//

import Foundation
import CoreData

@objc(Notification)
public class Notification: NSManagedObject {
   @nonobjc public class func fetchRequest() -> NSFetchRequest<Notification> {
       return NSFetchRequest<Notification>(entityName: "Notification")
   }

   @NSManaged public var id: UUID?
   @NSManaged public var habit: Habit?
}
