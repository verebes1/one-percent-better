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
   
   func wasCompleted(on date: Date) -> Bool {
      guard let i = daysCompleted.sameDayBinarySearch(for: date) else { return false }
      
      switch frequency(on: date) {
      case .timesPerDay(let n):
         return timesCompleted[i] >= n
      case .daysInTheWeek(_):
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
      guard let i = daysCompleted.sameDayBinarySearch(for: date) else { return 0 }
      
      switch frequency(on: date) {
      case .timesPerDay(let n):
         return Double(timesCompleted[i]) / Double(n)
      case .daysInTheWeek(_):
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
   
   /// Mark habit as completed for a date
   /// - Parameter date: The day to mark the habit completed
   func markCompleted(on date: Date) {
      if !wasCompleted(on: date) {
         if let i = daysCompleted.sameDayBinarySearch(for: date) {
            timesCompleted[i] += 1
            if let v = timesCompletedDict[DMYDate(date: date)] {
               timesCompletedDict[DMYDate(date: date)] = v + 1
            }
         } else {
            daysCompleted.append(date)
            timesCompleted.append(1)
            timesCompletedDict[DMYDate(date: date)] = 1
         }
         
         let combined = zip(daysCompleted, timesCompleted).sorted { $0.0 < $1.0 }
         daysCompleted = combined.map { $0.0 }
         timesCompleted = combined.map { $0.1 }
         
         if date < startDate {
            startDate = Cal.startOfDay(for: date)
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
         if let t = tracker as? Tracker {
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
}
