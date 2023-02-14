//
//  Habit+WasCompletedOn.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/31/22.
//

import Foundation


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
      guard let i = daysCompleted.sameDayBinarySearch(for: date),
            let freq = frequency(on: date) else {
         return false
      }
      
      switch freq {
      case .timesPerDay(let n):
         return timesCompleted[i] >= n
      case .daysInTheWeek(_), .timesPerWeek(_, _):
         return timesCompleted[i] >= 1
      }
   
      // Dictionary style
//      let dmyDate = DMYDate(date: date)
//
//      switch frequency(on: date) {
//      case .timesPerDay(let n):
//         if let t = timesCompletedDict[dmyDate], t >= n {
//            return true
//         }
//         return false
//      case .daysInTheWeek(_):
//         if let t = timesCompletedDict[dmyDate], t >= 1 {
//            return true
//         }
//         return false
//      }
   }
   
   func percentCompleted(on date: Date) -> Double {
      guard let i = daysCompleted.sameDayBinarySearch(for: date),
            let freq = frequency(on: date) else {
         return 0
      }
      
      switch freq {
      case .timesPerDay(let n):
         return Double(timesCompleted[i]) / Double(n)
      case .daysInTheWeek(_), .timesPerWeek(_, _):
         return timesCompleted[i] >= 1 ? 1 : 0
      }
      
      // Dictionary style
//      let dmyDate = DayMonthYearDate(date: date)
//
//      switch frequency(on: date) {
//      case .timesPerDay(let n):
//         if let t = timesCompletedDict[dmyDate] {
//            return Double(t) / Double(n)
//         }
//         return 0
//      case .daysInTheWeek(_):
//         if let t = timesCompletedDict[dmyDate], t >= 1 {
//            return 1
//         }
//         return 0
//      }
   }
   
   func timesCompleted(on date: Date) -> Int {
      guard let i = daysCompleted.sameDayBinarySearch(for: date) else { return 0 }
      return timesCompleted[i]
   }
   
   /// Only valid for habits with a frequency of timesPerWeek, returns how many times they've completed
   /// the habit this week, going back as far as the reset day
   /// - Parameter date: The day of the week to check against
   /// - Returns: Number of times completed that week
   func timesCompletedThisWeek(on date: Date) -> Int {
      guard let f = frequency(on: date), case .timesPerWeek(_, resetDay: let resetDay) = f else { return 0 }
      var timesCompletedThisWeek = 0
      
      let startOffset = date.weekdayInt - resetDay.rawValue
      let startDay = Cal.addDays(num: -startOffset, to: date)
      
      for i in 0 ..< 7 {
         let day = Cal.addDays(num: i, to: startDay)
         timesCompletedThisWeek += timesCompleted(on: day)
      }
      return timesCompletedThisWeek
   }
   
   /// Only valid for habits with a frequency of timesPerWeek, returns true if they've completed
   /// the habit more than or equal to the times expected for that week
   /// - Parameter date: The day of the week to check against
   /// - Returns: Whether or not they've completed the habit that week
   func wasCompletedThisWeek(on date: Date) -> Bool {
      guard let f = frequency(on: date), case .timesPerWeek(let times, _) = f else { return false }
      return timesCompletedThisWeek(on: date) >= times
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
      
      // add 1 if completed today
      if wasCompleted(on: date) {
         streak += 1
      }
      
      let dayBeforeDate = Cal.addDays(num: -1, to: date)
      // TODO: 1.0.8 number of days between isn't working as it should (adding 1 for some reason)
      let totalDays = Cal.numberOfDaysBetween(startDate, and: dayBeforeDate)
      guard totalDays >= 0 else { return 0 }
      for i in 0 ... totalDays {
         let day = Cal.addDays(num: -i, to: dayBeforeDate)
         guard let freq = frequency(on: date) else { return streak }
         switch freq {
         case .timesPerDay:
            if wasCompleted(on: day) {
               streak += 1
            } else {
               return streak
            }
         case .daysInTheWeek:
            if isDue(on: day) {
               if wasCompleted(on: day) {
                  streak += 1
               } else {
                  return streak
               }
            }
         case .timesPerWeek(_, let resetDay):
            if day.weekdayInt == resetDay.rawValue {
               if wasCompletedThisWeek(on: day) {
                  streak += 1
               } else {
                  return streak
               }
            }
         }
      }
      return streak
   }
}
