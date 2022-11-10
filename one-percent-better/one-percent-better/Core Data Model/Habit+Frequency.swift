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

// Frequency Data Structure
// frequencyDates: [Date] - LIST OF DATES OF WHEN FREQUENCY CHANGES
// Use index of frequencyDates in order to get frequency data
// All frequency data must be appeneded to keep the same length as frequencyDates array

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
   
   func frequency(on date: Date) -> HabitFrequency {
      guard let index = frequencyDates.lastIndex(where: { Cal.startOfDay(for: $0) <= Cal.startOfDay(for: date) }) else {
//         print("Requesting frequency on date which is after all dates in the frequencyDates array")
         return .timesPerDay(1)
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
}
