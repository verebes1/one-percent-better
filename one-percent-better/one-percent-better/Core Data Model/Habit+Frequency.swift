//
//  Habit+Frequency.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 11/1/22.
//

import Foundation

extension Date {
   // 0 = S, 1 = M, 2 = T, 3 = W, 4 = T, 5 = F, 6 = S
   var weekdayInt: Int {
      return Cal.component(.weekday, from: self) - 1
   }
}

@objc public enum HabitFrequencyNSManaged: Int {
   case timesPerDay = 0
   case specificWeekdays = 1
   case timesPerWeek = 2
   
   init(_ freq: HabitFrequency) {
      switch freq {
      case .timesPerDay(_):
         self = .timesPerDay
      case .specificWeekdays(_):
         self = .specificWeekdays
      case .timesPerWeek(_,_):
         self = .timesPerWeek
      }
   }
}

enum HabitFrequency: Equatable, Hashable {
   case timesPerDay(Int)
   case specificWeekdays([Weekday])
   case timesPerWeek(times: Int, resetDay: Weekday)
   
   var valueNS: Int {
      switch self {
      case .timesPerDay:
         return 0
      case .specificWeekdays:
         return 1
      case .timesPerWeek:
         return 2
      }
   }
   
   func equalType(to hf: HabitFrequency) -> Bool {
      return self.valueNS == hf.valueNS
   }
}

enum Weekday: Int, CustomStringConvertible, Comparable {
   case sunday, monday, tuesday, wednesday, thursday, friday, saturday
   
   init(_ date: Date) {
      self.init(rawValue: date.weekdayInt)!
   }
   
   init(_ weekdayInt: Int) {
      let modulo = weekdayInt % 7
      if modulo != weekdayInt {
         assertionFailure("Creating a Weekday with a weekdayInt out of range: \(weekdayInt)")
      }
      self.init(rawValue: modulo)!
   }
   
   var description: String {
      switch self {
      case .sunday: return "Sunday"
      case .monday: return "Monday"
      case .tuesday: return "Tuesday"
      case .wednesday: return "Wednesday"
      case .thursday: return "Thursday"
      case .friday: return "Friday"
      case .saturday: return "Saturday"
      }
   }
   
   static func < (lhs: Weekday, rhs: Weekday) -> Bool {
      return lhs.rawValue < rhs.rawValue
   }
   
   static func positiveDifference(from a: Weekday, to b: Weekday) -> Int {
      var diff = b.rawValue - a.rawValue
      if diff < 0 {
         diff += 7
      }
      return diff
   }
}

// TEMP ENUM WHILE TESTING UI
enum HabitFrequencyTest: Equatable {
   case timesPerDay(Int)
   case specificWeekdays([Int])
   case timesPerWeek(times: Int, resetDay: Weekday)
   case everyXDays(Int)
   
   var valueNS: Int {
      switch self {
      case .timesPerDay(_):
         return 0
      case .specificWeekdays(_):
         return 1
      case .timesPerWeek(_, _):
         return 2
      case .everyXDays(_):
         return 3
      }
   }
}

extension Habit {
   
   
   /// Add a frequency to this habit. If a frequency exists for this start date, then remove it
   /// - Parameters:
   ///   - frequency: The type of frequency
   ///   - startDate: The start date of the frequency
   func addFrequency(frequency: HabitFrequency, startDate: Date) {
      // Remove all frequencies that have that have the same startDate
      let freqToRemove = frequenciesArray.compactMap { Cal.isDate($0.startDate, inSameDayAs: startDate) ? $0 : nil }
      freqToRemove.forEach { self.removeFromFrequencies($0) }
      
      let newFrequency = createFrequency(frequency: frequency, startDate: startDate)
      self.addToFrequencies(newFrequency)
   }
   
   /// Create a new Frequency NSManagedObject
   /// - Parameters:
   ///   - frequency: The type of frequency
   ///   - startDate: The start date of the frequency
   /// - Returns: The frequency to return
   func createFrequency(frequency: HabitFrequency, startDate: Date) -> Frequency {
      var nsFrequency: Frequency
      switch frequency {
      case .timesPerDay(let n):
         nsFrequency = XTimesPerDayFrequency(context: moc, timesPerDay: n)
      case .specificWeekdays(let days):
         nsFrequency = SpecificWeekdaysFrequency(context: moc, weekdays: days)
      case .timesPerWeek(times: let n, resetDay: let day):
         nsFrequency = XTimesPerWeekFrequency(context: moc, timesPerWeek: n, resetDay: day)
      }
      nsFrequency.startDate = startDate
      return nsFrequency
   }
   
   /// Change the frequency on a specific date
   /// - Parameters:
   ///   - freq: The frequency to change to
   ///   - date: The date to change it on
   func changeFrequency(to frequency: HabitFrequency, on startDate: Date = Date()) {
      precondition(!frequenciesArray.isEmpty)
      
      let frequencyDates = frequenciesArray.map { $0.startDate }
      let newFrequency = createFrequency(frequency: frequency, startDate: startDate)
      
      if let i = frequencyDates.sameDayBinarySearch(for: startDate) {
         self.removeFromFrequencies(at: i)
         // TODO: 1.1.2 Don't add to frequency list if last frequency is equal to this frequency
         self.insertIntoFrequencies(newFrequency, at: i)
      } else {
         // index of first frequency whose start date is > new frequency startDate
         let insertIndex = frequencyDates.binarySearch { $0.startOfDay() <= startDate.startOfDay() }
         if let insertIndex = insertIndex {
            self.insertIntoFrequencies(newFrequency, at: insertIndex)
         } else {
            // TODO: 1.1.2 Don't add to frequency list if last frequency is equal to this frequency
            self.addToFrequencies(newFrequency)
         }
      }
      
      improvementTracker?.update(on: startDate)
      moc.assertSave()
   }
   
   
   /// Get the frequency of the habit on a specific date
   /// - Parameter date: The date to get the frequency on
   /// - Returns: The corresponding HabitFrequency
   func frequency(on date: Date) -> HabitFrequency? {
      let frequencyDates = frequenciesArray.map { $0.startDate }
      guard let index = frequencyDates.lastIndex(where: { Cal.startOfDay(for: $0) <= Cal.startOfDay(for: date) }) else {
         return nil
      }
      
      if let freq = frequencies[index] as? XTimesPerDayFrequency {
         return .timesPerDay(freq.timesPerDay)
      } else if let freq = frequencies[index] as? SpecificWeekdaysFrequency {
         let weekdays = freq.weekdays.map { Weekday($0) }
         return .specificWeekdays(weekdays)
      } else if let freq = frequencies[index] as? XTimesPerWeekFrequency {
         return .timesPerWeek(times: freq.timesPerWeek, resetDay: Weekday(freq.resetDay))
      }
      
      assertionFailure("Unknown frequency type")
      return nil
   }
   
   func isDue(on date: Date) -> Bool {
      guard started(before: date) else {
         return false
      }
      guard let freq = frequency(on: date) else { return false }
      return isDue(on: date, withFrequency: freq)
   }
   
   /// Check whether the habit is due on this date with this frequency
   /// - Parameters:
   ///   - date: The date to check against
   ///   - freq: The frequency to check against
   /// - Returns: True if due on this date with this frequency, false otherwise
   func isDue(on date: Date, withFrequency freq: HabitFrequency) -> Bool {
      switch freq {
      case .timesPerDay(_):
         return true
      case .specificWeekdays(let days):
         return days.contains(Weekday(date))
      case .timesPerWeek(_, resetDay: let resetDay):
         // Habit due all at once on the reset day, otherwise it would mess with daily percent calculations
         return date.weekdayInt == resetDay.rawValue
      }
   }
}
