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
   case daysInTheWeek = 1
   case timesPerWeek = 2
   
   init(_ freq: HabitFrequency) {
      switch freq {
      case .timesPerDay(_):
         self = .timesPerDay
      case .daysInTheWeek(_):
         self = .daysInTheWeek
      case .timesPerWeek(_,_):
         self = .timesPerWeek
      }
   }
}

enum HabitFrequency: Equatable, Hashable {
   case timesPerDay(Int)
   case daysInTheWeek([Weekday])
   case timesPerWeek(times: Int, resetDay: Weekday)
   
   var valueNS: Int {
      switch self {
      case .timesPerDay:
         return 0
      case .daysInTheWeek:
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
   case daysInTheWeek([Int])
   case timesPerWeek(times: Int, resetDay: Weekday)
   case everyXDays(Int)
   
   var valueNS: Int {
      switch self {
      case .timesPerDay(_):
         return 0
      case .daysInTheWeek(_):
         return 1
      case .timesPerWeek(_, _):
         return 2
      case .everyXDays(_):
         return 3
      }
   }
}

// Frequency Data Structure
// frequencyDates: [Date] - LIST OF DATES OF WHEN FREQUENCY CHANGES
// Use index of frequencyDates in order to get frequency data
// All frequency data must be appended to keep the same length as frequencyDates array
//
// Example:
// 1/1/2022  - Habit created with   1 time per day
// 1/5/2022  - freq changed to      2 times per day
// 1/14/2022 - freq changed to      MWF
// 2/3/2022  - freq changed to      3 times per day
//
// frequencyDates = [1/1/2022, 1/5/2022, 1/14/2022, 2/3/2022]
// frequency      = [0,        0,        1,         0       ]
// timesPerDay    = [1,        2,        1,         3       ]
// daysPerWeek    = [[0],      [0],      [0,2,4],   [0]     ]
//
// Note: the frequency dates array needs to match the start date of the habit, so it must
// be updated when the start date is updated

extension Habit {
   
   /// Change the frequency on a specific date
   /// - Parameters:
   ///   - freq: The frequency to change to
   ///   - date: The date to change it on
   func changeFrequency(to freq: HabitFrequency, on date: Date = Date()) {
      guard frequency.count == self.frequencyDates.count else {
         fatalError("frequency and frequencyDates out of whack")
      }
      
      if let i = frequencyDates.sameDayBinarySearch(for: date) {
         frequency[i] = freq.valueNS
         switch freq {
         case .timesPerDay(let n):
            timesPerDay[i] = n
         case .daysInTheWeek(let days):
            daysPerWeek[i] = days.map { $0.rawValue }
         case .timesPerWeek(times: let n, resetDay: let day):
            timesPerWeekTimes[i] = n
            timesPerWeekResetDay[i] = day.rawValue
         }
      } else {
         frequencyDates.append(date)
         frequency.append(freq.valueNS)
         
         timesPerDay.append(1)
         daysPerWeek.append([0])
         timesPerWeekTimes.append(1)
         timesPerWeekResetDay.append(0)
         
         switch freq {
         case .timesPerDay(let n):
            timesPerDay[timesPerDay.count - 1] = n
         case .daysInTheWeek(let days):
            daysPerWeek[daysPerWeek.count - 1] = days.map { $0.rawValue }
         case .timesPerWeek(times: let n, resetDay: let day):
            timesPerWeekTimes[timesPerWeekTimes.count - 1] = n
            timesPerWeekResetDay[timesPerWeekResetDay.count - 1] = day.rawValue
         }
      }
      self.improvementTracker?.update(on: date)
      moc.fatalSave()
   }
   
   
   /// Get the frequency of the habit on a specific date
   /// - Parameter date: The date to get the frequency on
   /// - Returns: The corresponding HabitFrequency
   func frequency(on date: Date) -> HabitFrequency? {
      guard let index = frequencyDates.lastIndex(where: { Cal.startOfDay(for: $0) <= Cal.startOfDay(for: date) }) else {
         return nil
      }
         
      guard let freq = HabitFrequencyNSManaged(rawValue: frequency[index]) else {
         fatalError("Unknown frequency")
      }
      
      switch freq {
      case .timesPerDay:
         return .timesPerDay(timesPerDay[index])
      case .daysInTheWeek:
         let weekdayArray = daysPerWeek[index].map { Weekday($0) }
         return .daysInTheWeek(weekdayArray)
      case .timesPerWeek:
         return .timesPerWeek(times: timesPerWeekTimes[index], resetDay: Weekday(timesPerWeekResetDay[index]))
      }
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
      case .daysInTheWeek(let days):
         return days.contains(Weekday(date))
      case .timesPerWeek(_, resetDay: let resetDay):
         // Habit due all at once on the reset day, otherwise it would mess with daily percent calculations
         return date.weekdayInt == resetDay.rawValue
      }
   }
}
