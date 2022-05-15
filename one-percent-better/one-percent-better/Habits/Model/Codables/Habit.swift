//
//  Habit.swift
//
//  Created by Jeremy on 4/11/21.
//

import Foundation
import CoreData
import UIKit

/// Error when managedObjectContext is unable to be pulled from decoder object.
/// The decoder's managedObjectContext should be set up when creating the JSONDecoder object
enum DecoderConfigurationError: Error {
    case missingManagedObjectContext
}

enum HabitCreationError: Error {
    case duplicateName
}

struct TrackersContainer: Codable {
    let numberTrackers: [NumberTracker]
    let improvementTracker: ImprovementTracker?
    let imageTrackers: [ImageTracker]
}

@objc(Habit)
public class Habit: NSManagedObject, Codable {
    
    // MARK: - NSManaged Properties
    
    /// The name of the habit
    @NSManaged private(set) var name: String
    
    /// The index of the habit in the table (to keep track of order)
    @NSManaged public var orderIndex: Int
    
    /// This variable is used to know the largest habit order index among existing habits when importing new habits
    /// Assuming the imported habits are well indexed (0 to highest), their new indices are largestIndexBeforeImporting + their imported indices
    /// Set to largest when importing the first habit, and set back to nil after finished importing
    static var nextLargestIndexBeforeImporting: Int?
    
    /// An ordered set of all the trackers for the habit
    @NSManaged public var trackers: NSOrderedSet
    
    /// The day the habit was first created (not completed)
    @NSManaged public var startDate: Date
    
    /// An array of all the days where the habit was completed
    @NSManaged public var daysCompleted: [Date]
    
    /// The time when the notification should be sent
    @NSManaged public var notificationTime: Date?
    
    // MARK: - Properties
    
    /// Current streak (streak = 1 if completed today, streak = 2 if completed today and yesterday, etc.)
    var streak: Int  {
        get {
            var streak = 0
            // start at yesterday, a streak is only broken if it's not completed by the end of the day
            var currentDay = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            while self.wasCompleted(on: currentDay) {
                streak += 1
                currentDay = Calendar.current.date(byAdding: .day, value: -1, to: currentDay)!
            }
            // add 1 if completed today
            if self.wasCompleted(on: Date()) {
                streak += 1
            }
            return streak
        }
    }
    
    /// The longest streak the user has completed for this habit
    var longestStreak: Int {
        get {
            var longest = 0
            var current = 0
            var curDay = startDate
            while !Calendar.current.isDateInTomorrow(curDay) {
                if self.wasCompleted(on: curDay) {
                    current += 1
                    if current > longest {
                        longest = current
                    }
                } else {
                    current = 0
                }
                curDay = Calendar.current.date(byAdding: .day, value: 1, to: curDay)!
            }
            return longest
        }
    }
    
    var manualTrackers: [Tracker] {
        var manualTrackers: [Tracker] = []
        for tracker in trackers {
            if let t = tracker as? Tracker,
               !t.autoTracker {
                manualTrackers.append(t)
            }
        }
        return manualTrackers
    }
    
    // MARK: - init
    
    convenience init(context: NSManagedObjectContext, name: String) throws {
        // Check for a duplicate habit. Habits are unique by name
        let habits = Habit.updateHabitList(from: context)
        for habit in habits {
            if habit.name == name {
                throw HabitCreationError.duplicateName
            }
        }
        self.init(context: context)
        self.name = name
        self.startDate = Date()
        self.daysCompleted = []
        self.trackers = NSOrderedSet.init(array: [])
        self.orderIndex = nextLargestHabitIndex(habits)
    }
    
    func nextLargestHabitIndex(_ habits: [Habit]) -> Int {
        return habits.isEmpty ? 0 : habits.count
    }
    
    func setName(_ name: String) throws {
        // Check for a duplicate habit. Habits are unique by name
        let habits = Habit.updateHabitList(from: CoreDataManager.shared.mainContext)
        for habit in habits {
            if habit.name == name {
                throw HabitCreationError.duplicateName
            }
        }
        self.name = name
    }
    
    func wasCompleted(on date: Date) -> Bool {
        for day in daysCompleted {
            if Calendar.current.isDate(day, inSameDayAs: date) {
                return true
            }
        }
        return false
    }

    func markCompleted(on date: Date) {
        if !wasCompleted(on: date) {
            daysCompleted.append(date)
            daysCompleted.sort()
            
            if date < startDate {
                startDate = date
            }
            
            CoreDataManager.shared.saveContext()
        }
    }

    func markNotCompleted(on date: Date) {
        // Mark habit as not completed on this day
        for day in daysCompleted {
            if Calendar.current.isDate(day, inSameDayAs: date) {
                let index = daysCompleted.firstIndex(of: day)!
                daysCompleted.remove(at: index)
                CoreDataManager.shared.saveContext()
            }
        }
        
        // Remove tracker entries for this date
        for tracker in trackers {
            if let t = tracker as? Tracker {
                t.remove(on: date)
            }
        }
    }
    
    class func updateHabitList(from context: NSManagedObjectContext) -> [Habit] {
        var habits: [Habit] = []
        do {
            // fetch all habits
            let fetchRequest: NSFetchRequest<Habit> = Habit.fetchRequest()
            habits = try context.fetch(fetchRequest)
        } catch {
            fatalError("Habit.swift \(#function) - unable to fetch habits! Error: \(error)")
        }
        
        // Sort habits by order index
        habits.sort(by: { habit1, habit2 in
            habit1.orderIndex < habit2.orderIndex
        })
        
        // Ensure that habits are properly indexed 0 ... highest
        for (i, habit) in habits.enumerated() {
            if habit.orderIndex != i {
                print("ERROR: order index of habits not properly indexed for \(habit.name)")
                habit.orderIndex = i
            }
        }
        
        // Debug habit index order
//        print("---------")
//        for habit in habits {
//            print("index: \(habit.orderIndex), name: \(habit.name)")
//        }
        
        return habits
    }
    
    /// Sort trackers by their index property
    func sortTrackers() {
        guard var trackerArray = self.trackers.array as? [Tracker] else {
            fatalError("Can't convert habit.trackers into [Tracker]")
        }
        
        trackerArray.sort { tracker1, tracker2 in
            tracker1.index < tracker2.index
        }
        
        // Ensure that trackers are properly indexed 0 ... highest
        for (i, tracker) in trackerArray.enumerated() {
            if tracker.index != i {
                print("ERROR: index of trackers not properly indexed for habit: \(self.name), tracker: \(tracker.name)")
                tracker.index = i
            }
        }
        
        // For some reason replaceTrackers(at idx: Int, with value: Tracker) doesn't work,
        // so reorder trackers this way
        self.removeFromTrackers(self.trackers)
        for t in trackerArray {
            self.addToTrackers(t)
        }
    }
    
    // MARK: - Encodable
    
    enum CodingKeys: CodingKey {
        case name
        case orderIndex
        case startDate
        case daysCompleted
        case notificationTime
        
        case trackersContainer
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw DecoderConfigurationError.missingManagedObjectContext
        }
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
    
        let habits = Habit.updateHabitList(from: context)
        var name = try container.decode(String.self, forKey: .name)
        let today = Date()
        for habit in habits {
            if habit.name == name {
                name = "\(name) (Imported on \(ExportManager.formatter.string(from: today)))"
            }
        }
        
        self.init(context: context)
        self.name = name
        self.startDate = try container.decode(Date.self, forKey: .startDate)
        self.daysCompleted = try container.decode([Date].self, forKey: .daysCompleted)
        self.notificationTime = try container.decode(Date?.self, forKey: .notificationTime)
        
        // If importing data on top of existing data, then we must add
        // the imported index on top of the largest existing index
        // NOTE: This depends on the imported file have proper indices
        let importedIndex = try container.decode(Int.self, forKey: .orderIndex)
        
        var existingIndex: Int
        if let hasExistingIndex = Habit.nextLargestIndexBeforeImporting {
            existingIndex = hasExistingIndex
        } else {
            existingIndex = nextLargestHabitIndex(habits)
            Habit.nextLargestIndexBeforeImporting = existingIndex
        }
        self.orderIndex = existingIndex + importedIndex
        
        let trackersContainer = try container.decode(TrackersContainer.self, forKey: .trackersContainer)
        for nt in trackersContainer.numberTrackers {
            nt.habit = self
            self.addToTrackers(nt)
        }
        if let it = trackersContainer.improvementTracker {
            it.habit = self
            self.addToTrackers(it)
        }
        for it in trackersContainer.imageTrackers {
            it.habit = self
            self.addToTrackers(it)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(orderIndex, forKey: .orderIndex)
        
        // Bundle up trackers into a container struct
        var numberTrackers: [NumberTracker] = []
        var improvementTracker: ImprovementTracker?
        var imageTrackers: [ImageTracker] = []
        for tracker in trackers {
            if let t = tracker as? NumberTracker {
                numberTrackers.append(t)
            } else if let t = tracker as? ImprovementTracker {
                improvementTracker = t
            } else if let t = tracker as? ImageTracker {
                imageTrackers.append(t)
            }
        }
        let trackersContainer = TrackersContainer(numberTrackers: numberTrackers, improvementTracker: improvementTracker, imageTrackers: imageTrackers)
        try container.encode(trackersContainer, forKey: .trackersContainer)
        
        try container.encode(startDate, forKey: .startDate)
        try container.encode(daysCompleted, forKey: .daysCompleted)
        try container.encode(notificationTime, forKey: .notificationTime)
    }
}

// MARK: Generated accessors for trackers
extension Habit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Habit> {
        return NSFetchRequest<Habit>(entityName: "Habit")
    }

    @objc(insertObject:inTrackersAtIndex:)
    @NSManaged public func insertIntoTrackers(_ value: Tracker, at idx: Int)

    @objc(removeObjectFromTrackersAtIndex:)
    @NSManaged public func removeFromTrackers(at idx: Int)

    @objc(insertTrackers:atIndexes:)
    @NSManaged public func insertIntoTrackers(_ values: [Tracker], at indexes: NSIndexSet)

    @objc(removeTrackersAtIndexes:)
    @NSManaged public func removeFromTrackers(at indexes: NSIndexSet)

    @objc(replaceObjectInTrackersAtIndex:withObject:)
    @NSManaged public func replaceTrackers(at idx: Int, with value: Tracker)

    @objc(replaceTrackersAtIndexes:withTrackers:)
    @NSManaged public func replaceTrackers(at indexes: NSIndexSet, with values: [Tracker])

    @objc(addTrackersObject:)
    @NSManaged public func addToTrackers(_ value: Tracker)

    @objc(removeTrackersObject:)
    @NSManaged public func removeFromTrackers(_ value: Tracker)

    @objc(addTrackers:)
    @NSManaged public func addToTrackers(_ values: NSOrderedSet)

    @objc(removeTrackers:)
    @NSManaged public func removeFromTrackers(_ values: NSOrderedSet)

}
