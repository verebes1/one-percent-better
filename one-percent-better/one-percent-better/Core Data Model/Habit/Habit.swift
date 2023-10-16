//
//  Habit.swift
//
//  Created by Jeremy on 4/11/21.
//

import Foundation
import CoreData
import UIKit
import SwiftUI
import Combine

/// Error when managedObjectContext is unable to be pulled from decoder object.
/// The decoder's managedObjectContext should be set up when creating the JSONDecoder object
enum DecoderConfigurationError: Error {
    case missingManagedObjectContext
}

enum HabitCreationError: Error {
    case duplicate
}

struct TrackersContainer: Codable {
    let numberTrackers: [NumberTracker]
    let improvementTracker: ImprovementTracker?
    let imageTrackers: [ImageTracker]
    let exerciseTrackers: [ExerciseTracker]?
}

@objc(Habit)
public class Habit: NSManagedObject, Codable, Identifiable, NamedEntity {
    
    static var entityName = "Habit"
    
    // MARK: - NSManaged Properties
    
    /// Unique identifier
    @NSManaged public var id: UUID
    
    /// The name of the habit
    @NSManaged private(set) var name: String
    
    /// The index of the habit in the table (to keep track of ordering)
    @NSManaged public var orderIndex: Int
    
    /// This variable is used to know the largest habit order index among existing habits when importing new habits
    /// Assuming the imported habits are well indexed (0 to highest), their new indices are largestIndexBeforeImporting + their imported indices
    /// This is set to the current largest index + 1 when importing the first habit, and set back to nil after importing the last habit
    static var nextLargestIndexBeforeImporting: Int?
    
    /// The start date of the habit. Any day before this start date doesn't display the habit in the habit list or count towards
    /// the total percent completed for that day.
    @NSManaged private(set) var startDate: Date
    
    /// An array of all the days where the habit was completed
    @NSManaged public var daysCompleted: [Date]
    
    /// How many times they've completed the habit, where each entry corresponds to an entry in the daysCompleted
    /// array. For example if the habit was completed twice for a particular day, the entry would be 2
    @NSManaged public var timesCompleted: [Int]
    
    /// An ordered set of all the trackers for the habit
    @NSManaged public var trackers: NSOrderedSet
    var trackersArray: [Tracker] { trackers.asArray() }
    
    /// A set of notifications for this habit
    @NSManaged public var notifications: NSOrderedSet
    var notificationsArray: [Notification] { notifications.asArray() }
    
    /// A set of frequencies for this habit
    @NSManaged public var frequencies: NSOrderedSet
    var frequenciesArray: [Frequency] { frequencies.asArray() }
    
    var moc: NSManagedObjectContext = CoreDataManager.shared.mainContext
    
    /// Class which manages scheduling notifications, retrieving notification messages from OpenAI, remove notifications, etc.
    var notificationManager: NotificationManager = NotificationManager.shared
    
    /// Override CustomStringConvertible
    public override var description: String {
        self.name
    }
    
    // MARK: - init
    @discardableResult
    convenience init(context: NSManagedObjectContext,
                     name: String,
                     frequency: HabitFrequency = .timesPerDay(1),
                     id: UUID = UUID()) throws {
        // Check for a duplicate habit. Habits are unique by id
        let habits = Habit.habits(from: context)
        for habit in habits {
            if habit.id == id {
                throw HabitCreationError.duplicate
            }
        }
        self.init(context: context)
        moc = context
        self.name = name
        self.id = id
        startDate = Date()
        daysCompleted = []
        timesCompleted = []
        trackers = NSOrderedSet.init(array: [])
        orderIndex = nextLargestHabitIndex(habits)
        updateFrequency(to: frequency, on: startDate)
        addToTrackers(ImprovementTracker(context: moc, habit: self))
    }
    
    convenience init(moc: NSManagedObjectContext,
                     name: String,
                     id: UUID) {
        try! self.init(context: moc, name: name, id: id)
    }
    
    func updateStartDate(to date: Date) {
        let date = date.startOfDay
        
        // Ensure the new start date is not in the future
        let tmr = Cal.add(days: 1).startOfDay
        guard date < tmr else { return }
        
        // Ensure we have a non empty frequency array
        guard let firstFrequency = frequenciesArray.first else {
            assertionFailure("Frequency array should never be empty")
            return
        }
        
        // Ensure we are not updating start date past first completed date (destroying data)
        if let firstCompleted = daysCompleted.first {
            guard date <= firstCompleted else {
                assertionFailure("Trying to update start date past first completed date")
                return
            }
        }
        
        // Ensure we are not updating past the first frequency change
        if frequenciesArray.count > 1 {
            let secondFrequency = frequenciesArray[1]
            guard date < secondFrequency.startDate else {
                assertionFailure("Unhandled case for changing start date of habit past first frequency change")
                return
            }
        }
        
        startDate = date
        firstFrequency.updateStartDate(to: date)
        
        improvementTracker?.recalculateScoreFromBeginning()
        moc.assertSave()
    }
    
    func updateName(to newName: String) {
        guard newName != name else { return }
        self.name = newName
        for notification in notificationsArray {
            notification.completeReset()
        }
        notificationManager.rebalanceHabitNotifications()
    }
    
    var editableTrackers: [Tracker] {
        trackersArray.filter { !$0.autoTracker }
    }
    
    var hasTimeTracker: Bool {
        for tracker in trackers {
            if let _ = tracker as? TimeTracker {
                return true
            }
        }
        return false
    }
    
    var timeTracker: TimeTracker? {
        for tracker in trackers {
            if let t = tracker as? TimeTracker {
                return t
            }
        }
        return nil
    }
    
    func nextLargestHabitIndex(_ habits: [Habit]) -> Int {
        return habits.isEmpty ? 0 : habits.count
    }
    
    /// Whether or not this habits start date is after or equal to a certain date
    /// - Parameter day: The day to check against
    /// - Returns: True if the habit started on or after the date, and false otherwise
    func started(after day: Date) -> Bool {
        return startDate.startOfDay >= day.startOfDay
    }
    
    /// Whether or not this habits start date is before or equal to a certain date
    /// - Parameter day: The day to check against
    /// - Returns: True if the habit started on or before the date, and false otherwise
    func started(before day: Date) -> Bool {
        return startDate.startOfDay <= day.startOfDay
    }
    
    class func habits(from context: NSManagedObjectContext) -> [Habit] {
        return context.fetchArray(Habit.self)
    }
    
    /// Sort trackers by their index property
    func sortTrackers() {
        var trackerArray = self.trackersArray
        
        // Sort by index
        trackerArray.sort { $0.index < $1.index }
        
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
    
    func cleanUp() {
        // Remove delivered notifications
        NotificationManager.shared.removeDeliveredNotifications(habitID: id)
        
        // Remove pending notifications
        for notification in notificationsArray {
            notification.removePendingNotifications()
        }
    }
    
    // MARK: - Encodable
    
    enum CodingKeys: CodingKey {
        case name
        case id
        case orderIndex
        case startDate
        case daysCompleted
        case timesCompleted
        case trackersContainer
        
        // TODO: 1.0.9 Add notifications container
        // TODO: 1.1.2 Add frequencies container
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw DecoderConfigurationError.missingManagedObjectContext
        }
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let habits = Habit.habits(from: context)
        var name = try container.decode(String.self, forKey: .name)
        let today = Date()
        for habit in habits {
            if habit.name == name {
                name = "\(name) (Imported on \(ExportManager.formatter.string(from: today)))"
            }
        }
        
        self.init(context: context)
        self.name = name
        self.id = container.decodeOptional(key: .id, type: UUID.self) ?? UUID()
        self.startDate = container.decodeOptional(key: .startDate, type: Date.self) ?? Date()
        self.daysCompleted = container.decodeOptional(key: .daysCompleted, type: [Date].self) ?? []
        self.timesCompleted = container.decodeOptional(key: .timesCompleted, type: [Int].self) ?? Array(repeating: 1, count: daysCompleted.count)
        
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
        
        if let trackersContainer = try? container.decode(TrackersContainer.self, forKey: .trackersContainer) {
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
            if let ets = trackersContainer.exerciseTrackers {
                for it in ets {
                    it.habit = self
                    self.addToTrackers(it)
                }
            }
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(id, forKey: .id)
        try container.encode(orderIndex, forKey: .orderIndex)
        
        // Bundle up trackers into a container struct
        var numberTrackers: [NumberTracker] = []
        var improvementTracker: ImprovementTracker?
        var imageTrackers: [ImageTracker] = []
        var exerciseTrackers: [ExerciseTracker] = []
        for tracker in trackers {
            if let t = tracker as? NumberTracker {
                numberTrackers.append(t)
            } else if let t = tracker as? ImprovementTracker {
                improvementTracker = t
            } else if let t = tracker as? ImageTracker {
                imageTrackers.append(t)
            } else if let t = tracker as? ExerciseTracker {
                exerciseTrackers.append(t)
            }
        }
        let trackersContainer = TrackersContainer(numberTrackers: numberTrackers, improvementTracker: improvementTracker, imageTrackers: imageTrackers, exerciseTrackers: exerciseTrackers)
        try container.encode(trackersContainer, forKey: .trackersContainer)
        
        try container.encode(startDate, forKey: .startDate)
        try container.encode(daysCompleted, forKey: .daysCompleted)
        try container.encode(timesCompleted, forKey: .timesCompleted)
    }
}

// MARK: Fetch Request

extension Habit: HasFetchRequest {
    static func fetchRequest<T>() -> NSFetchRequest<T> {
        let fetchRequest = NSFetchRequest<T>(entityName: "Habit")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Habit.orderIndex, ascending: true)]
        return fetchRequest
    }
}

// MARK: Generated accessors for trackers
extension Habit {
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

// MARK: Generated accessors for notifications
extension Habit {
    
    @objc(insertObject:inNotificationsAtIndex:)
    @NSManaged public func insertIntoNotifications(_ value: Notification, at idx: Int)
    
    @objc(removeObjectFromNotificationsAtIndex:)
    @NSManaged public func removeFromNotifications(at idx: Int)
    
    @objc(insertNotifications:atIndexes:)
    @NSManaged public func insertIntoNotifications(_ values: [Notification], at indexes: NSIndexSet)
    
    @objc(removeNotificationsAtIndexes:)
    @NSManaged public func removeFromNotifications(at indexes: NSIndexSet)
    
    @objc(replaceObjectInNotificationsAtIndex:withObject:)
    @NSManaged public func replaceNotifications(at idx: Int, with value: Notification)
    
    @objc(replaceNotificationsAtIndexes:withNotifications:)
    @NSManaged public func replaceNotifications(at indexes: NSIndexSet, with values: [Notification])
    
    @objc(addNotificationsObject:)
    @NSManaged public func addToNotifications(_ value: Notification)
    
    @objc(removeNotificationsObject:)
    @NSManaged public func removeFromNotifications(_ value: Notification)
    
    @objc(addNotifications:)
    @NSManaged public func addToNotifications(_ values: NSOrderedSet)
    
    @objc(removeNotifications:)
    @NSManaged public func removeFromNotifications(_ values: NSOrderedSet)
}

// MARK: Generated accessors for frequencies
extension Habit {
    
    @objc(insertObject:inFrequenciesAtIndex:)
    @NSManaged public func insertIntoFrequencies(_ value: Frequency, at idx: Int)
    
    @objc(removeObjectFromFrequenciesAtIndex:)
    @NSManaged public func removeFromFrequencies(at idx: Int)
    
    @objc(insertFrequencies:atIndexes:)
    @NSManaged public func insertIntoFrequencies(_ values: [Frequency], at indexes: NSIndexSet)
    
    @objc(removeFrequenciesAtIndexes:)
    @NSManaged public func removeFromFrequencies(at indexes: NSIndexSet)
    
    @objc(replaceObjectInFrequenciesAtIndex:withObject:)
    @NSManaged public func replaceFrequencies(at idx: Int, with value: Frequency)
    
    @objc(replaceFrequenciesAtIndexes:withFrequencies:)
    @NSManaged public func replaceFrequencies(at indexes: NSIndexSet, with values: [Frequency])
    
    @objc(addFrequenciesObject:)
    @NSManaged public func addToFrequencies(_ value: Frequency)
    
    @objc(removeFrequenciesObject:)
    @NSManaged public func removeFromFrequencies(_ value: Frequency)
    
    @objc(addFrequencies:)
    @NSManaged public func addToFrequencies(_ values: NSOrderedSet)
    
    @objc(removeFrequencies:)
    @NSManaged public func removeFromFrequencies(_ values: NSOrderedSet)
}

extension Habit {
    static func resultsController(context: NSManagedObjectContext,
                                  sortDescriptors: [NSSortDescriptor] = [],
                                  predicate: NSPredicate? = nil) -> NSFetchedResultsController<Habit> {
        let request = NSFetchRequest<Habit>(entityName: "Habit")
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors.isEmpty ? nil : sortDescriptors
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }
}

extension KeyedDecodingContainer {
    func decodeOptional<T: Decodable>(key: KeyedDecodingContainer.Key, type: T.Type) -> T? {
        if let value = try? self.decode(T.self, forKey: key) {
            return value
        }
        return nil
    }
}
