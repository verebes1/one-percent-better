//
//  Habit+Frequency.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 11/1/22.
//

import Foundation

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

enum HabitFrequency: Equatable, Hashable {
   case timesPerDay(Int)
   case daysInTheWeek([Int])
//   case timesPerWeek(Int) // TODO: finish implementing
   
   var valueNS: Int {
      switch self {
      case .timesPerDay(_):
         return 0
      case .daysInTheWeek(_):
         return 1
//      case .timesPerWeek(_):
//         return 2
      }
   }
   
   /// For converting between a date and the weekday (for ex. M = 1, T = 2, W = 3, ...)
   /// - Parameter date: The date to convert
   /// - Returns: The integer value of that weekday
   func dateToDaysInTheWeek(for date: Date) -> Int {
      return Cal.component(.weekday, from: date) - 1
   }
   
   func equalType(to hf: HabitFrequency) -> Bool {
      return self.valueNS == hf.valueNS
   }
}

enum Weekday {
   case monday, tuesday, wednesday, thursday, friday, saturday, sunday
}

// TEMP ENUM WHILE TESTING UI
enum HabitFrequencyTest: Equatable {
   case timesPerDay(Int)
   case daysInTheWeek([Int])
   case timesPerWeek(times: Int, resetDay: Weekday)
   
   var valueNS: Int {
      switch self {
      case .timesPerDay(_):
         return 0
      case .daysInTheWeek(_):
         return 1
      case .timesPerWeek(_, _):
         return 2
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
            daysPerWeek[i] = days
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
      moc.fatalSave()
   }
   
   
   /// Get the frequency of the habit on a specific date
   /// - Parameter date: The date to get the frequency on
   /// - Returns: The corresponding HabitFrequency
   func frequency(on date: Date) -> HabitFrequency? {
      guard let index = frequencyDates.lastIndex(where: { Cal.startOfDay(for: $0) <= Cal.startOfDay(for: date) }) else {
         // Requesting frequency before start date
//         print("ERROR!!! frequency is nil on date: \(String(describing: date))")
         return nil
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
      guard let freq = frequency(on: date) else {
         return false
      }
      
//      guard started(after: date) else {
//         return false
//      }
      
      switch freq {
      case .timesPerDay(_):
         return true
      case .daysInTheWeek(let days):
         return days.contains(date.weekdayInt)
      }
   }
}
