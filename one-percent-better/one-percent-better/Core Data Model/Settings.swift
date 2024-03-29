//
//  Settings+CoreDataClass.swift
//  
//
//  Created by Jeremy Cook on 10/19/22.
//
//

import Foundation
import CoreData
import SwiftUI

@objc(Settings)
public class Settings: NSManagedObject, NamedEntity {
    
    static var entityName = "Settings"
    
    /// The app-wide appearance
    /// System = 0
    /// Light = 1
    /// Dark = 2
    @NSManaged public var appearance: Int
    
    /// Appearance converted to ColorScheme
    var appearanceScheme: ColorScheme? {
        switch appearance {
        case 1:
            return .light
        case 2:
            return .dark
        default:
            return nil
        }
    }
    
    /// Whether the daily reminder notification is on or not
    @NSManaged public var dailyReminderEnabled: Bool
    
    /// What time to send the daily reminder notification if it's on
    @NSManaged public var dailyReminderTime: Date
    
    /// Which day to start the week on (Sunday = 0 or Monday = 1)
    @NSManaged public var startingWeekdayInt: Int
    
    /// The starting weekday as a Weekday
    var startOfWeek: Weekday {
        return Weekday(rawValue: startingWeekdayInt) ?? .monday
    }
    
    convenience init(myContext: NSManagedObjectContext) {
        self.init(context: myContext)
        self.appearance = 0
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
