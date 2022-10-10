//
//  Habit.swift
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
   case duplicateName
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

@objc(Habit)
public class Habit: NSManagedObject, Codable, Identifiable {
   
   // MARK: - NSManaged Properties
   
   /// Unique identifier
   public var id = UUID()
   
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
   
   // MARK: - Properties
   
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
   
   var editableTrackers: [Tracker] {
      var editable: [Tracker] = []
      for tracker in trackers {
         if let t = tracker as? Tracker {
            if let _ = t as? ImprovementTracker {
               // don't add
            } else {
               editable.append(t)
            }
         }
      }
      return editable
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
   
   var moc: NSManagedObjectContext = CoreDataManager.shared.mainContext
   
   // MARK: - init
   
   convenience init(context: NSManagedObjectContext,
                    name: String,
                    noNameDupe: Bool = true,
                    frequency: HabitFrequency = .timesPerDay(1)) throws {
      // Check for a duplicate habit. Habits are unique by name
      let habits = Habit.habits(from: context)
      if noNameDupe {
         for habit in habits {
            if habit.name == name {
               throw HabitCreationError.duplicateName
            }
         }
      }
      self.init(context: context)
      self.moc = context
      self.name = name
      let today = Date()
      self.startDate = Calendar.current.startOfDay(for: today)
      self.daysCompleted = []
      self.trackers = NSOrderedSet.init(array: [])
      self.orderIndex = nextLargestHabitIndex(habits)
      

      let managedFreq = HabitFrequencyNSManaged(frequency)
      self.frequency = [managedFreq.rawValue]
      self.frequencyDates = [startDate]
      
      // Default values
      self.timesPerDay = [1]
      self.daysPerWeek = [[2,4]]
      
      switch frequency {
      case .timesPerDay(let n):
         self.timesPerDay = [n]
      case .daysInTheWeek(let days):
         self.daysPerWeek = [days]
      }
   }
   
   func nextLargestHabitIndex(_ habits: [Habit]) -> Int {
      return habits.isEmpty ? 0 : habits.count
   }
   
   func setName(_ name: String) throws {
      // Check for a duplicate habit. Habits are unique by name
      let habits = Habit.habits(from: moc)
      for habit in habits {
         if habit.name == name {
            throw HabitCreationError.duplicateName
         }
      }
      self.name = name
   }
   
   func wasCompleted(on date: Date) -> Bool {
      for (i, day) in daysCompleted.enumerated() {
         if Calendar.current.isDate(day, inSameDayAs: date) {
            switch frequency(on: date) {
            case .timesPerDay(let n):
               return timesCompleted[i] >= n
            case .daysInTheWeek(_):
               return timesCompleted[i] >= 1
            }
         }
      }
      return false
   }
   
   func percentCompleted(on date: Date) -> Double {
      for (i, day) in daysCompleted.enumerated() {
         if Calendar.current.isDate(day, inSameDayAs: date) {
            switch frequency(on: date) {
            case .timesPerDay(let n):
               return Double(timesCompleted[i]) / Double(n)
            case .daysInTheWeek(_):
               return timesCompleted[i] >= 1 ? 1 : 0
            }
         }
      }
      return 0
   }
   
   func timesCompleted(on date: Date) -> Int {
      for (i, day) in daysCompleted.enumerated() {
         if Calendar.current.isDate(day, inSameDayAs: date) {
            return timesCompleted[i]
         }
      }
      return 0
   }
   
   /// Mark habit as completed for a date
   /// - Parameter date: The day to mark the habit completed
   func markCompleted(on date: Date) {
      if !wasCompleted(on: date) {
         if let index = daysCompleted.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: date) }) {
            timesCompleted[index] += 1
         } else {
            daysCompleted.append(date)
            timesCompleted.append(1)
         }
         
         let combined = zip(daysCompleted, timesCompleted).sorted { $0.0 < $1.0 }
         daysCompleted = combined.map { $0.0 }
         timesCompleted = combined.map { $0.1 }
         
         if date < startDate {
            startDate = Calendar.current.startOfDay(for: date)
         }
         moc.fatalSave()
      }
      
      updateImprovement()
   }
   
   func markNotCompleted(on date: Date) {
      // Mark habit as not completed on this day
      for day in daysCompleted {
         if Calendar.current.isDate(day, inSameDayAs: date) {
            let index = daysCompleted.firstIndex(of: day)!
            daysCompleted.remove(at: index)
            timesCompleted.remove(at: index)
         }
      }
      
      // Remove tracker entries for this date
      for tracker in trackers {
         if let t = tracker as? Tracker {
            t.remove(on: date)
         }
      }
      
      moc.fatalSave()
      
      updateImprovement()
   }
   
   func updateImprovement() {
      for tracker in trackers {
         if let t = tracker as? ImprovementTracker {
            t.update()
            continue
         }
      }
   }
   
   func toggle(on day: Date) {
      if wasCompleted(on: day) {
         markNotCompleted(on: day)
      } else {
         markCompleted(on: day)
         HapticEngineManager.playHaptic()
      }
   }
   
   /// Change the frequency on a specific date
   /// - Parameters:
   ///   - freq: The frequency to change to
   ///   - date: The date to change it on
   func changeFrequency(to freq: HabitFrequency, on date: Date = Date()) {
      guard frequency.count == self.frequencyDates.count else {
         fatalError("frequency and frequencyDates out of whack")
      }
      
      if let index = frequencyDates.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: date) } ) {
      
         frequency[index] = freq.valueNS
         
         switch freq {
         case .timesPerDay(let n):
            timesPerDay[index] = n
         case .daysInTheWeek(let days):
            daysPerWeek[index] = days
         }
      } else {
         frequencyDates.append(date)
         frequency.append(freq.valueNS)
         
         timesPerDay.append(1)
         daysPerWeek.append([0])
         
         switch freq {
         case .timesPerDay(let n):
            timesPerDay[timesPerDay.count - 1] = n
         case .daysInTheWeek(let days):
            daysPerWeek[daysPerWeek.count - 1] = days
         }
      }
   }
   
   func frequency(on date: Date) -> HabitFrequency {
      
      guard let index = frequencyDates.lastIndex(where: { Calendar.current.startOfDay(for: $0) <= Calendar.current.startOfDay(for: date) }) else {
         fatalError("Requesting frequency on date which is after all dates in the frequencyDates array")
      }
         
      guard let freq = HabitFrequencyNSManaged(rawValue: frequency[index]) else {
         fatalError("Unknown frequency")
      }
      
      switch freq {
      case .timesPerDay:
         return .timesPerDay(timesPerDay[index])
      case .daysInTheWeek:
         return .daysInTheWeek(daysPerWeek[index])
      }
   }
   
   func isDue(on date: Date) -> Bool {
      switch frequency(on: date) {
      case .timesPerDay(_):
         return true
      case .daysInTheWeek(let days):
         return days.contains(date.weekdayOffset)
      }
   }
   
   /// Whether or not this habit started after a certain date
   /// - Parameter day: The day to check against
   /// - Returns: True if the habit started on or after the date, and false otherwise
   func started(after day: Date) -> Bool {
      return Calendar.current.startOfDay(for: startDate) <= Calendar.current.startOfDay(for: day)
   }
   
   class func habits(from context: NSManagedObjectContext) -> [Habit] {
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
   
   public override func prepareForDeletion() {
      guard let trackerArray = self.trackers.array as? [Tracker] else {
         fatalError("Can't convert habit.trackers into [Tracker]")
      }
      for tracker in trackerArray {
         moc.delete(tracker)
      }
      moc.fatalSave()
   }
   
   // MARK: - Encodable
   
   enum CodingKeys: CodingKey {
      case name
      case orderIndex
      case startDate
      case daysCompleted
      case notificationTime
      case frequency
      case frequencyDates
      case timesPerDay
      case timesCompleted
      case daysPerWeek
      
      case trackersContainer
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
      self.startDate = try container.decode(Date.self, forKey: .startDate)
      self.daysCompleted = try container.decode([Date].self, forKey: .daysCompleted)
      self.notificationTime = try container.decode(Date?.self, forKey: .notificationTime)
      self.frequency = container.decodeOptional(key: .frequency, type: [Int].self) ?? [HabitFrequencyNSManaged.timesPerDay.rawValue]
      self.frequencyDates = container.decodeOptional(key: .frequencyDates, type: [Date].self) ?? [startDate]
      self.timesPerDay = container.decodeOptional(key: .timesPerDay, type: [Int].self) ?? [1]
      self.timesCompleted = container.decodeOptional(key: .timesCompleted, type: [Int].self) ?? Array(repeating: 1, count: daysCompleted.count)
      self.daysPerWeek = container.decodeOptional(key: .daysPerWeek, type: [[Int]].self) ?? [[0]]
      
      if self.daysPerWeek.isEmpty {
         self.daysPerWeek = Array(repeating: [2,4], count: self.frequency.count)
      }
      
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
      try container.encode(notificationTime, forKey: .notificationTime)
      try container.encode(frequency, forKey: .frequency)
      try container.encode(frequencyDates, forKey: .frequencyDates)
      try container.encode(timesPerDay, forKey: .timesPerDay)
      try container.encode(timesCompleted, forKey: .timesCompleted)
      try container.encode(daysPerWeek, forKey: .daysPerWeek)
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

extension Habit {
   static func resultsController(context: NSManagedObjectContext, sortDescriptors: [NSSortDescriptor] = []) -> NSFetchedResultsController<Habit> {
      let request = NSFetchRequest<Habit>(entityName: "Habit")
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
