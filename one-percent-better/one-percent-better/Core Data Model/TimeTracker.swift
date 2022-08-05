//
//  TimeTracker+CoreDataClass.swift
//
//
//  Created by Jeremy Cook on 6/29/22.
//
//

import Foundation
import CoreData
import Combine

@objc(TimeTracker)
public class TimeTracker: Tracker {

    @NSManaged public var dates: [Date]
    @NSManaged public var values: [Int]
    @NSManaged public var goalTime: Int
    
    var myContext: NSManagedObjectContext?
    
    var isRunning: Bool = false
    var currentDay: Date?
    var currentTimeCounter: Int = 0
    var timerPublisher: Timer.TimerPublisher?
    var cancelBag: AnyCancellable?
    var callback: ((Int) -> Void)?
    
    convenience init(context: NSManagedObjectContext, habit: Habit, goalTime: Int?) {
        self.init(context: context)
        self.myContext = context
        self.habit = habit
        self.name = habit.name + " Time Tracker"
        self.autoTracker = true
        self.dates = []
        self.values = []
        self.goalTime = goalTime ?? 0
        
        // Create a number tracker for time
    }
    
    func addSec(on date: Date) {
        if let dateIndex = dates.firstIndex(where: { day in Calendar.current.isDate(day, inSameDayAs: date) }) {
            values[dateIndex] += 1
        } else {
            dates.append(date)
            values.append(0)
            
            // Sort by dates
            let combined = zip(dates, values).sorted { $0.0 < $1.0 }
            dates = combined.map { $0.0 }
            values = combined.map { $0.1 }
        }
        context.fatalSave()
    }
    
    func getValue(on date: Date) -> Int? {
        if let i = dates.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: date) }) {
            return values[i]
        } else {
            return nil
        }
    }
    
    func toggleTimer(on date: Date) {
        if currentDay == nil || currentDay != date || cancelBag == nil {
            currentDay = date
            self.cancelBag = Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { date in
                print("received date: \(date)")
                if self.isRunning {
                    self.habit.timeTracker?.addSec(on: date)
                    if let currentTime = self.habit.timeTracker?.getValue(on: date),
                       let callback = self.callback {
                        callback(currentTime)
                    }
                }
            }
        }
        isRunning = !isRunning
        
        if !isRunning {
            self.cancelBag = nil
        }
    }
}

extension TimeTracker {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TimeTracker> {
        return NSFetchRequest<TimeTracker>(entityName: "TimeTracker")
    }


}
