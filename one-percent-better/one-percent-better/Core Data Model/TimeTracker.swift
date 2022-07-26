//
//  TimeTracker+CoreDataClass.swift
//
//
//  Created by Jeremy Cook on 6/29/22.
//
//

import Foundation
import CoreData

@objc(TimeTracker)
public class TimeTracker: Tracker {

    @NSManaged public var dates: [Date]
    @NSManaged public var values: [Int]
    
    @NSManaged public var goalTime: Int
    
    convenience init(context: NSManagedObjectContext, habit: Habit, goalTime: Int?) {
        self.init(context: context)
        self.habit = habit
        self.name = habit.name + " Time Tracker"
        self.autoTracker = false
        self.dates = []
        self.values = []
        self.goalTime = goalTime ?? 0
    }
    
}

extension TimeTracker {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TimeTracker> {
        return NSFetchRequest<TimeTracker>(entityName: "TimeTracker")
    }


}