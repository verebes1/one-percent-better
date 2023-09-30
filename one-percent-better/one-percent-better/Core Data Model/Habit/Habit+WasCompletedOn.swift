//
//  Habit+WasCompletedOn.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/31/22.
//

import Foundation

extension Habit {
    var improvementTracker: ImprovementTracker? {
        trackersArray.first { $0 is ImprovementTracker } as? ImprovementTracker
    }
    
    var firstCompleted: Date? {
        daysCompleted.first
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
        case .specificWeekdays(_), .timesPerWeek(_, _):
            return timesCompleted[i] >= 1
        }
    }
    
    func percentCompleted(on date: Date) -> Double {
        guard let freq = frequency(on: date) else { return 0 }
        switch freq {
        case .timesPerDay(let n):
            return Double(timesCompleted(on: date)) / Double(n)
        case .specificWeekdays(_):
            return timesCompleted(on: date) >= 1 ? 1 : 0
        case .timesPerWeek(times: let n, resetDay: let resetDay):
            if Weekday(Cal.add(days: 1, to: date)) == resetDay {
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
    func timesCompletedThisWeek(on date: Date,
                                withFrequency freq: HabitFrequency,
                                upTo: Bool = false) -> Int {
        var resetWeekday: Weekday
        switch freq {
        case .timesPerDay:
            return 0
        case .specificWeekdays:
            resetWeekday = StartOfWeekModel.shared.startOfWeek
        case .timesPerWeek(_, let tpwResetDay):
            resetWeekday = tpwResetDay
        }
        
        // Go back to last reset day
        let startDay = Cal.mostRecent(weekday: resetWeekday, before: date, includingDate: true)
        
        var timesCompletedThisWeek = 0
        for i in 0 ..< 7 {
            let day = Cal.add(days: i, to: startDay)
            timesCompletedThisWeek += timesCompleted(on: day)
            if upTo && Cal.isDate(day, inSameDayAs: date) {
                break
            }
        }
        return timesCompletedThisWeek
    }
    
    /// If this habit was completed on the week containing this day
    /// - Parameter date: The date in the week
    /// - Returns: True if completed this week, false if not
    func wasCompletedThisWeek(on date: Date) -> Bool {
        guard let freq = frequency(on: date) else { return false }
        return wasCompletedThisWeek(on: date, withFrequency: freq)
    }
    
    /// Only valid for habits with a frequency of timesPerWeek, returns true if they've completed
    /// the habit more than or equal to the times expected for that week
    /// - Parameter date: The day of the week to check against
    /// - Parameter freq: The frequency to check against
    /// - Returns: Whether or not they've completed the habit that week
    func wasCompletedThisWeek(on date: Date, withFrequency freq: HabitFrequency, upTo: Bool = false) -> Bool {
        switch freq {
        case .timesPerDay:
            return false
        case .specificWeekdays(let set):
            let times = set.count
            return timesCompletedThisWeek(on: date, withFrequency: freq, upTo: upTo) >= times
        case .timesPerWeek(let times, _):
            return timesCompletedThisWeek(on: date, withFrequency: freq, upTo: upTo) >= times
        }
    }
    
    /// Mark habit as completed for a date
    /// - Parameter date: The day to mark the habit completed
    func markCompleted(on date: Date) {
        if !wasCompleted(on: date) {
            if let i = daysCompleted.sameDayBinarySearch(for: date) {
                timesCompleted[i] += 1
            } else {
                daysCompleted.append(date)
                timesCompleted.append(1)
            }
            
            let combined = zip(daysCompleted, timesCompleted).sorted { $0.0 < $1.0 }
            daysCompleted = combined.map { $0.0 }
            timesCompleted = combined.map { $0.1 }
            
            if date < startDate {
                updateStartDate(to: date)
            }
        }
        
        // Remove notifications for today if fully completed
        if let freq = frequency(on: date) {
            switch freq {
            case .timesPerDay(let n):
                if timesCompleted(on: date) == n {
                    removeNotifications(on: date)
                } else {
                    removeDeliveredNotifications()
                }
            case .specificWeekdays, .timesPerWeek:
                removeNotifications(on: date)
            }
        }
        
        improvementTracker?.update(on: date)
        moc.assertSave()
    }
    
    /// Mark the habit as not completed on this date
    /// - Parameter date: The date
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
        addNotificationsBack(on: date)
        moc.assertSave()
    }
    
    /// Toggle the habit completion on this date
    /// If this habit should be completed multiples times
    /// per day, then this will increase it by 1, similar to tapping
    /// on the completion circle in the UI
    /// - Parameter day: The date to toggle
    func toggle(on day: Date) {
        if wasCompleted(on: day) {
            markNotCompleted(on: day)
        } else {
            markCompleted(on: day)
            HapticEngineManager.playHaptic()
        }
    }
    
    /// The streak of this habit calculated on specific date
    ///
    /// A streak isn't broken until the user doesn't complete it when it's due. For daily habits, this means a streak from the previous day is still valid even if the habit
    /// wasn't completed today. For weekly habits, a streak from the previous week is still valid even if the habit hasn't been completed this week yet.
    /// - Parameter date: The streak on this date
    /// - Returns: The streak number
    func streak(on date: Date) -> Int {
        guard let freq = frequency(on: date) else { return 0 }
        var streak = 0
        
        switch freq {
        case .timesPerDay:
            var day = date
            while started(before: day) {
                if wasCompleted(on: day, withFrequency: freq) {
                    streak += 1
                } else if day == date {
                    // Forgive the current day
                    continue
                } else {
                    break
                }
                day = Cal.add(days: -1, to: day)
            }
            return streak
            
        case .specificWeekdays:
            var day = date
            while started(before: day) {
                if wasCompletedThisWeek(on: day, withFrequency: freq, upTo: true) {
                    streak += 1
                } else if day == date {
                    // Forgive the current week
                } else {
                    break
                }
                
                // Go back to the day before the last reset day
                let lastResetDay = Cal.mostRecent(weekday: StartOfWeekModel.shared.startOfWeek, before: day, includingDate: true)
                let diff = Cal.numberOfDays(from: lastResetDay, to: day) + 1
                day = Cal.add(days: -diff, to: day)
                
                // Edge case where we go back to the first week which might not start on the start of the week
//                day = Cal.add(days: -diff, to: day)
//                if started(after: day) && firstWeek {
//                    day = startDate
//                    firstWeek = true
//                }
            }
            return streak
        case .timesPerWeek(_, let resetDay):
            var day = date
            while started(before: day) {
                if wasCompletedThisWeek(on: day, withFrequency: freq, upTo: true) {
                    streak += 1
                } else if day == date {
                    // Forgive the current week
                } else {
                    break
                }
                
                // Go back to the day before the last reset day
                let lastResetDay = Cal.mostRecent(weekday: resetDay, before: day, includingDate: true)
                let diff = Cal.numberOfDays(from: lastResetDay, to: day) + 1
                day = Cal.add(days: -diff, to: day)
                
//                // Edge case where we go back to the first week which might not start on the start of the week
//                if started(after: day) && firstWeek {
//                    day = startDate
//                    firstWeek = true
//                }
            }
            return streak
        }
        
    }
    
//    /// The streak of this habit calculated on specific date
//    /// - Parameter date: The streak on this date
//    /// - Returns: The streak number
//    func streakOld(on date: Date) -> Int {
//        var streak = 0
//        
//        guard let freq = frequency(on: date) else { return 0 }
//        let numDaysToCheck = Cal.numberOfDays(from: startDate, to: date)
//        
//        // A streak isn't broken until the user doesn't complete it when it's due,
//        // so first we calculate how many days to go backward to start calculating
//        // the streak. For daily habits, we need to go to yesterday (if the habit
//        // wasn't completed today), and for weekly habits, we need to go back to the
//        // start of the previous week (if the habit wasn't completed this week)
//        var goBackStart = 0
//        if numDaysToCheck > 0 {
//            switch freq {
//            case .timesPerDay:
//                if !wasCompleted(on: date, withFrequency: freq) {
//                    goBackStart = 1
//                }
//            case .specificWeekdays:
//                if !wasCompletedThisWeek(on: date, withFrequency: freq, upTo: true) {
//                    // Go back to the day before the last reset day
//                    let lastResetDay = Cal.mostRecent(weekday: StartOfWeekModel.shared.startOfWeek, before: date, includingDate: true)
//                    let diff = Cal.numberOfDays(from: lastResetDay, to: date) + 1
//                    goBackStart = min(diff, numDaysToCheck)
//                }
//            case .timesPerWeek(_, resetDay: let resetDay):
//                if !wasCompletedThisWeek(on: date, withFrequency: freq, upTo: true) {
//                    // Go back to the day before the last reset day
//                    let lastResetDay = Cal.mostRecent(weekday: resetDay, before: date, includingDate: true)
//                    let diff = Cal.numberOfDays(from: lastResetDay, to: date) + 1
//                    goBackStart = min(diff, numDaysToCheck)
//                }
//            }
//        }
//        
//        // Flags to keep track of if the streak was increased for this week already,
//        // so that it's not increased multiple times for the same week
//        var dayBeforeNewWeek = false
//        var alreadyCompletedThisWeek = false
//        
//        for i in goBackStart ... numDaysToCheck {
//            let day = Cal.add(days: -i, to: date)
//            switch freq {
//            case .timesPerDay:
//                if wasCompleted(on: day, withFrequency: freq) {
//                    streak += 1
//                } else {
//                    return streak
//                }
//            case .specificWeekdays:
//                // Reset for new week
//                if day.weekdayIndex == StartOfWeekModel.shared.startOfWeek.index && dayBeforeNewWeek {
//                    alreadyCompletedThisWeek = false
//                    dayBeforeNewWeek = false
//                }
//                
//                if wasCompletedThisWeek(on: day, withFrequency: freq, upTo: true) {
//                    if !alreadyCompletedThisWeek {
//                        streak += 1
//                        alreadyCompletedThisWeek = true
//                    }
//                } else {
//                    return streak
//                }
//                
//                // Day before start of week
//                if Cal.add(days: -1, to: day).weekdayIndex == StartOfWeekModel.shared.startOfWeek.index {
//                    dayBeforeNewWeek = true
//                }
//            case .timesPerWeek:
//                if isDue(on: day, withFrequency: freq) && dayBeforeNewWeek {
//                    alreadyCompletedThisWeek = false
//                    dayBeforeNewWeek = false
//                }
//                
//                if wasCompletedThisWeek(on: day, withFrequency: freq, upTo: true) {
//                    if !alreadyCompletedThisWeek {
//                        streak += 1
//                        alreadyCompletedThisWeek = true
//                    }
//                } else {
//                    return streak
//                }
//                
//                if isDue(on: Cal.add(days: -2, to: day), withFrequency: freq) {
//                    dayBeforeNewWeek = true
//                }
//            }
//        }
//        return streak
//    }
    
    /// How many days since the last time this habit was completed
    /// - Parameter on: The date to check against
    func notDoneInDays(on day: Date) -> Int? {
        // Ensure habit has been started
        guard started(before: day) else {
            return nil
        }
        
        // Ensure habit has been completed at least once
        guard !daysCompleted.isEmpty else {
            return nil
        }
        
        guard !Cal.isDate(day, inSameDayAs: startDate) else {
            return wasCompleted(on: day) ? 0 : nil
        }
        var difference = 0
        var day = day
        while !wasCompleted(on: day) {
            difference += 1
            day = Cal.add(days: -1, to: day)
            guard started(before: day) else {
                break
            }
        }
        return difference
    }
    
    /// How many weeks since the last time this habit was completed
    /// - Parameter on: The date to check against
    func notDoneInWeeks(on date: Date) -> Int? {
        // Ensure habit has been started
        guard started(before: date) else {
            return nil
        }
        
        // Ensure habit has been completed at least once
        guard !daysCompleted.isEmpty else {
            return nil
        }
        
        guard let freq = frequency(on: date) else {
            return nil
        }
        
        guard !Cal.isDate(date, inSameDayAs: startDate) else {
            return wasCompletedThisWeek(on: date, withFrequency: freq, upTo: true) ? 1 : nil
        }
        
        var day = date
        var weeks = 0
        
        while !wasCompletedThisWeek(on: day) {
            // Forgive the current week
            if day != date {
                weeks += 1
            }
            switch freq {
            case .timesPerDay:
                assertionFailure("Should not be called")
            case .specificWeekdays:
                // Go back to the day before the last reset day
                let lastResetDay = Cal.mostRecent(weekday: StartOfWeekModel.shared.startOfWeek, before: day, includingDate: true)
                let diff = Cal.numberOfDays(from: lastResetDay, to: day) + 1
                day = Cal.add(days: -diff, to: day)
            case .timesPerWeek(_, let resetDay):
                // Go back to the day before the last reset day
                let lastResetDay = Cal.mostRecent(weekday: resetDay, before: day, includingDate: true)
                let diff = Cal.numberOfDays(from: lastResetDay, to: day) + 1
                day = Cal.add(days: -diff, to: day)
            }
            
            guard started(before: day) else {
                break
            }
        }
        return weeks
    }
}
