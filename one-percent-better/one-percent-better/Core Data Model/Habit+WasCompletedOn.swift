//
//  Habit+WasCompletedOn.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/31/22.
//

import Foundation

// TODO: At some point, also implement dictionary containing completed days for faster lookup than binary search
// Dictionary style (key must be hashable, and equatable for same day):
// let dmyDate = DMYDate(date: date)

extension Habit {
   
   var improvementTracker: ImprovementTracker? {
      for tracker in trackers {
         if let t = tracker as? ImprovementTracker {
            return t
         }
      }
      return nil
   }
   
   var firstCompleted: Date? {
      guard let day = daysCompleted.first else { return nil }
      return day
   }
   
   func wasCompleted(on date: Date) -> Bool {
      guard let freq = frequency(on: date) else { return false }
      return wasCompleted(on: date, withFrequency: freq)
   }
   
   func wasCompleted(on date: Date, withFrequency freq: HabitFrequency) -> Bool {
      guard let i = daysCompleted.sameDayBinarySearch(for: date) else {
         return false
      }
      
      switch freq {
      case .timesPerDay(let n):
         return timesCompleted[i] >= n
      case .daysInTheWeek(_), .timesPerWeek(_, _):
         return timesCompleted[i] >= 1
      }
   }
   
   func percentCompleted(on date: Date) -> Double {
      guard let freq = frequency(on: date) else { return 0 }
      switch freq {
      case .timesPerDay(let n):
         guard let i = daysCompleted.sameDayBinarySearch(for: date) else { return 0 }
         return Double(timesCompleted[i]) / Double(n)
      case .daysInTheWeek(_):
         guard let i = daysCompleted.sameDayBinarySearch(for: date) else { return 0 }
         return timesCompleted[i] >= 1 ? 1 : 0
      case .timesPerWeek(times: let n, resetDay: let resetDay):
         if date.weekdayInt == resetDay.rawValue {
            let ans = Double(timesCompletedThisWeek(on: date)) / Double(n)
            return min(1, ans)
         } else {
            return 0
         }
      }
   }
   
   func timesCompleted(on date: Date) -> Int {
      guard let i = daysCompleted.sameDayBinarySearch(for: date) else { return 0 }
      return timesCompleted[i]
   }
   
   func timesCompletedThisWeek(on date: Date, upTo: Bool = false) -> Int {
      guard let freq = frequency(on: date) else { return 0 }
      return timesCompletedThisWeek(on: date, withFrequency: freq, upTo: upTo)
   }
   
   /// Only valid for habits with a frequency of timesPerWeek, returns how many times they've completed
   /// the habit this week, going back as far as the reset day
   /// - Parameter date: The day of the week to check against
   /// - Parameter freq: The frequency to check against
   /// - Parameter upTo: Calculate only up to this date
   /// - Returns: Number of times completed that week
   func timesCompletedThisWeek(on date: Date, withFrequency freq: HabitFrequency, upTo: Bool = false) -> Int {
      guard case .timesPerWeek(_, resetDay: let resetDay) = freq else { return 0 }
      var timesCompletedThisWeek = 0
      
      var startOffset = Weekday.positiveDifference(from: resetDay, to: Weekday(date)) - 1
      if startOffset < 0 {
         startOffset += 7
      }
      let startDay = Cal.add(days: -startOffset, to: date)
      
      for i in 0 ..< 7 {
         let day = Cal.add(days: i, to: startDay)
         timesCompletedThisWeek += timesCompleted(on: day)
         if upTo && Cal.isDate(day, inSameDayAs: date) {
            break
         }
      }
      return timesCompletedThisWeek
   }
   
   func wasCompletedThisWeek(on date: Date) -> Bool {
      guard let freq = frequency(on: date) else { return false }
      return wasCompletedThisWeek(on: date, withFrequency: freq)
   }
   
   /// Only valid for habits with a frequency of timesPerWeek, returns true if they've completed
   /// the habit more than or equal to the times expected for that week
   /// - Parameter date: The day of the week to check against
   /// - Parameter freq: The frequency to check against
   /// - Returns: Whether or not they've completed the habit that week
   func wasCompletedThisWeek(on date: Date, withFrequency freq: HabitFrequency) -> Bool {
      guard case .timesPerWeek(let times, _) = freq else { return false }
      return timesCompletedThisWeek(on: date, withFrequency: freq) >= times
   }
   
   /// Mark habit as completed for a date
   /// - Parameter date: The day to mark the habit completed
   func markCompleted(on date: Date) {
      if !wasCompleted(on: date) {
         if let i = daysCompleted.sameDayBinarySearch(for: date) {
            timesCompleted[i] += 1
            
            // Dictionary version
            if let v = timesCompletedDict[DMYDate(date: date)] {
               timesCompletedDict[DMYDate(date: date)] = v + 1
            }
         } else {
            daysCompleted.append(date)
            timesCompleted.append(1)
            
            // Dictionary version
            timesCompletedDict[DMYDate(date: date)] = 1
         }
         
         let combined = zip(daysCompleted, timesCompleted).sorted { $0.0 < $1.0 }
         daysCompleted = combined.map { $0.0 }
         timesCompleted = combined.map { $0.1 }
         
         if date < startDate {
            updateStartDate(to: date)
         }
      }
      
      improvementTracker?.update(on: date)
      moc.fatalSave()
   }
   
   func markNotCompleted(on date: Date) {
      // Mark habit as not completed on this day
      if let i = daysCompleted.sameDayBinarySearch(for: date) {
         daysCompleted.remove(at: i)
         timesCompleted.remove(at: i)
      }
      
      // Remove tracker entries for this date
      for tracker in trackers {
         if let t = tracker as? Tracker,
            !t.autoTracker {
            t.remove(on: date)
         }
      }
      
      // Fix this at some point
      improvementTracker?.update(on: date)
      moc.fatalSave()
   }
   
   func toggle(on day: Date) {
      if wasCompleted(on: day) {
         markNotCompleted(on: day)
      } else {
         markCompleted(on: day)
         HapticEngineManager.playHaptic()
      }
   }
   
   /// The streak of this habit calculated on specific date
   /// - Parameter date: The streak on this date
   /// - Returns: The streak number
   func streak(on date: Date) -> Int {
      var streak = 0
      
      guard let freq = frequency(on: date) else { return 0 }
      let numDaysToCheck = Cal.numberOfDaysBetween(startDate, and: date)
      
      // A streak isn't broken until the user doesn't complete it when it's due,
      // so first we calculate how many days to go backward to start calculating
      // the streak. For daily habits, we need to go to yesterday (if the habit
      // wasn't completed today), and for weekly habits, we need to go back to the
      // start of the previous week (if the habit wasn't completed this week)
      var goBackStart = 0
      if numDaysToCheck > 0 {
         switch freq {
         case .timesPerDay:
            if !wasCompleted(on: date, withFrequency: freq) {
               goBackStart = 1
            }
         case .daysInTheWeek:
            // TODO: 1.0.8
            break
         case .timesPerWeek(_, resetDay: let resetDay):
            if !wasCompletedThisWeek(on: date, withFrequency: freq) {
               let lastResetDay = Cal.getLast(weekday: resetDay, from: date)
               let diff = Cal.numberOfDaysBetween(lastResetDay, and: date)
               if diff <= numDaysToCheck {
                  goBackStart = diff
               }
            }
         }
      }
      
      
      // Flags to keep track if the streak was increased for this week already,
      // so that it's not increased multiple times for the same week
      var dayBeforeNewWeek = false
      var alreadyCompletedThisWeek = false
      
      for i in goBackStart ... numDaysToCheck {
         let day = Cal.add(days: -i, to: date)
         switch freq {
         case .timesPerDay:
            if wasCompleted(on: day, withFrequency: freq) {
               streak += 1
            } else {
               return streak
            }
         case .daysInTheWeek:
            if isDue(on: day, withFrequency: freq) {
               if wasCompleted(on: day, withFrequency: freq) {
                  streak += 1
               } else {
                  return streak
               }
            }
         case .timesPerWeek:
            if isDue(on: day, withFrequency: freq) && dayBeforeNewWeek {
               alreadyCompletedThisWeek = false
               dayBeforeNewWeek = false
            }
            
            if wasCompletedThisWeek(on: day, withFrequency: freq) {
               if !alreadyCompletedThisWeek {
                  streak += 1
                  alreadyCompletedThisWeek = true
               }
            } else {
               return streak
            }
            
            if isDue(on: Cal.add(days: -1, to: day), withFrequency: freq) {
               dayBeforeNewWeek = true
            }
         }
      }
      return streak
   }
   
   /// How many days since the last time this habit was completed
   /// - Parameter on: The date to check against
   func notDoneInDays(on date: Date) -> Int? {
      guard started(after: date) else { return nil }
      var difference = 0
      var day = Cal.startOfDay(for: date)
      day = Cal.add(days: -1, to: day)
      if day > startDate {
         while !wasCompleted(on: day) {
            difference += 1
            day = Cal.add(days: -1, to: day)
            if day < startDate {
               break
            }
         }
         return difference
      } else {
         return nil
      }
   }
}
