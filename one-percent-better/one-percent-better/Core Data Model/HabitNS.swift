//
//  HabitNS.swift
//
//  Created by Jeremy on 4/11/21.
//

import Foundation
import CoreData
import UIKit
import SwiftUI

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

@objc public enum HabitFrequencyNSManaged: Int {
   case timesPerDay = 0
   case daysInTheWeek = 1
   
   init(_ freq: HabitFrequency) {
      switch freq {
      case .timesPerDay(_):
         self = .timesPerDay
      case .daysInTheWeek(_):
         self = .daysInTheWeek
      }
   }
}

enum HabitFrequency: Equatable {
   case timesPerDay(Int)
   case daysInTheWeek([Int])
   
   var valueNS: Int {
      switch self {
      case .timesPerDay(_):
         return 0
      case .daysInTheWeek(_):
         return 1
      }
   }
   
   func equalType(to hf: HabitFrequency) -> Bool {
      return self.valueNS == hf.valueNS
   }
}

@objc(HabitNS)
public class HabitNS: NSManagedObject, Identifiable {
   
   // MARK: - NSManaged Properties
   
   /// Unique identifier
   @NSManaged public var id: UUID
   
   /// The name of the habit
   @NSManaged public var name: String
   
   /// The index of the habit in the table (to keep track of ordering)
   @NSManaged public var orderIndex: Int
   
   /// This variable is used to know the largest habit order index among existing habits when importing new habits
   /// Assuming the imported habits are well indexed (0 to highest), their new indices are largestIndexBeforeImporting + their imported indices
   /// This is set to the current largest index + 1 when importing the first habit, and set back to nil after importing the last habit
   static var nextLargestIndexBeforeImporting: Int?
   
   /// An ordered set of all the trackers for the habit
   @NSManaged public var trackers: NSOrderedSet
   
   /// The day the habit was first created (not completed)
   @NSManaged public var startDate: Date
   
   /// An array of all the days where the habit was completed
   @NSManaged public var daysCompleted: [Date]
   
   /// The time when the notification should be sent
   @NSManaged public var notificationTime: Date?
   
   /// How frequently the user wants to complete the habit (daily, weekly, monthly)
   @NSManaged public var frequency: [Int]
   
   /// The dates the user switches the frequency of their habits, so that their previous data is still shown as completed
   @NSManaged public var frequencyDates: [Date]
   
   /// How many times they've completed the habit, where each entry corresponds to an entry in the daysCompleted
   /// array. For example if the habit was completed twice for a particular day, the entry would be 2
   @NSManaged public var timesCompleted: [Int]
   
   /// If frequency is daily, how many times per day
   @NSManaged public var timesPerDay: [Int]
   
   /// A length 7 array for the days per week to complete this habit, stored as [S, M, T, W, T, F, S]
   /// For example, if you complete this habit on MWF, this array is [false, true, false, true, false, true, false]
   @NSManaged public var daysPerWeek: [[Int]]
   
   
   /// Whether or not this habit started after a certain date
   /// - Parameter day: The day to check against
   /// - Returns: True if the habit started on or after the date, and false otherwise
   func started(after day: Date) -> Bool {
      return Calendar.current.startOfDay(for: startDate) >= Calendar.current.startOfDay(for: day)
   }
   
   func started(before day: Date) -> Bool {
      return Calendar.current.startOfDay(for: startDate) <= Calendar.current.startOfDay(for: day)
   }
}

// MARK: Generated accessors for trackers
extension HabitNS {
   
   @nonobjc public class func fetchRequest() -> NSFetchRequest<HabitNS> {
      return NSFetchRequest<HabitNS>(entityName: "HabitNS")
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

extension Habit {
   static func resultsController(context: NSManagedObjectContext,
                                 sortDescriptors: [NSSortDescriptor] = [],
                                 predicate: NSPredicate? = nil) -> NSFetchedResultsController<HabitNS> {
      let request = NSFetchRequest<HabitNS>(entityName: "HabitNS")
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

extension Date {
   var weekdayOffset: Int {
      return Calendar.current.component(.weekday, from: self) - 1
   }
}
