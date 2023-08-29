//
//  Habit+Frequency.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 11/1/22.
//

import Foundation

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
    
    /// A readable description of the frequency
    /// For ex: "3 times a day" or "every Monday, Wednesday, Friday"
    var description: String {
        switch self {
        case .timesPerDay(let n):
            let times = n > 1 ? "times" : "time"
            return "\(n) \(times) per day"
        case .specificWeekdays(let weekdays):
            var result = "every "
            for (index, weekday) in weekdays.enumerated() {
                result += weekday.description
                if index != weekdays.count - 1 {
                    result += ", "
                }
            }
            return result
        case .timesPerWeek(let n, let resetDay):
            let times = n > 1 ? "times" : "time"
            return "\(n) \(times) per week beginning every \(resetDay.description)"
        }
    }
}

extension Habit {
    /// Change the frequency on a specific date
    /// - Parameters:
    ///   - freq: The frequency to change to
    ///   - date: The date to change it on
    func updateFrequency(to frequency: HabitFrequency, on startDate: Date = Date()) {
        guard self.started(before: startDate) else {
            fatalError("Can't change frequency before start date")
        }
        let frequencyDates = frequenciesArray.map { $0.startDate }
        let newFrequency = createFrequency(frequency: frequency, startDate: startDate)
        
        if let i = frequencyDates.sameDayBinarySearch(for: startDate) {
            self.removeFromFrequencies(at: i)
            self.insertIntoFrequencies(newFrequency, at: i)
        } else {
            // index of first frequency whose start date is > new frequency startDate
            let insertIndex = frequencyDates.binarySearch { $0.startOfDay <= startDate.startOfDay }
            if let insertIndex = insertIndex {
                self.insertIntoFrequencies(newFrequency, at: insertIndex)
            } else {
                self.addToFrequencies(newFrequency)
            }
        }
        
        frequencySquash()
        improvementTracker?.update(on: startDate)
        moc.assertSave()
    }
    
    /// Create a new Frequency NSManagedObject
    /// - Parameters:
    ///   - frequency: The type of frequency
    ///   - startDate: The start date of the frequency
    /// - Returns: The frequency to return
    private func createFrequency(frequency: HabitFrequency, startDate: Date) -> Frequency {
        var nsFrequency: Frequency
        switch frequency {
        case .timesPerDay(let n):
            nsFrequency = XTimesPerDayFrequency(context: moc, timesPerDay: n)
        case .specificWeekdays(let days):
            nsFrequency = SpecificWeekdaysFrequency(context: moc, weekdays: days)
        case .timesPerWeek(times: let n, resetDay: let day):
            nsFrequency = XTimesPerWeekFrequency(context: moc, timesPerWeek: n, resetDay: day)
        }
        nsFrequency.updateStartDate(to: startDate)
        return nsFrequency
    }
    
    /// If two frequencies of the same type follow one another, they should be squashed together.
    /// I.e. the second one should be removed.
    private func frequencySquash() {
        var indicesToRemove: [Int] = []
        for i in 0 ..< frequenciesArray.count {
            if (i + 1) == frequenciesArray.count {
                break
            }
            let currentFreq = convertNSFrequencyToHabitFrequency(nsFrequency: frequenciesArray[i])
            let nextFreq = convertNSFrequencyToHabitFrequency(nsFrequency: frequenciesArray[i + 1])
            if currentFreq == nextFreq {
                indicesToRemove.append(i + 1)
            }
        }
        
        for index in indicesToRemove.reversed() {
            removeFromFrequencies(at: index)
        }
    }
    
    
    /// Get the frequency of the habit on a specific date
    /// - Parameter date: The date to get the frequency on
    /// - Returns: The corresponding HabitFrequency
    func frequency(on date: Date) -> HabitFrequency? {
        guard started(before: date) else { return nil }
        let frequencyDates = frequenciesArray.map { $0.startDate }
        guard let index = frequencyDates.lastIndex(where: { Cal.startOfDay(for: $0) <= Cal.startOfDay(for: date) }) else {
            return nil
        }
        return convertNSFrequencyToHabitFrequency(nsFrequency: frequenciesArray[index])
    }
    
    /// Convert the NSManagedObject Frequency into a HabitFrequency enum
    /// - Parameter nsFrequency: The frequency object
    /// - Returns: The HabitFrequency for that Frequency
    func convertNSFrequencyToHabitFrequency(nsFrequency: Frequency) -> HabitFrequency? {
        if let freq = nsFrequency as? XTimesPerDayFrequency {
            return .timesPerDay(freq.timesPerDay)
        } else if let freq = nsFrequency as? SpecificWeekdaysFrequency {
            let weekdays = freq.weekdays.map { Weekday(rawValue: $0)! }
            return .specificWeekdays(weekdays)
        } else if let freq = nsFrequency as? XTimesPerWeekFrequency {
            return .timesPerWeek(times: freq.timesPerWeek, resetDay: Weekday(rawValue: freq.resetDay)!)
        }
        assertionFailure("Unknown frequency type: \(type(of: nsFrequency))")
        return nil
    }
    
    /// Check whether this habit is due on this date
    /// - Parameter date: The date to check against
    /// - Returns: True if due and false if not
    func isDue(on date: Date) -> Bool {
        guard started(before: date) else { return false }
        guard let freq = frequency(on: date) else { return false }
        return isDue(on: date, withFrequency: freq)
    }
    
    /// Check whether the habit is due on this date with this frequency
    /// - Parameters:
    ///   - date: The date to check against
    ///   - freq: The frequency to check against
    /// - Returns: True if due on this date with this frequency, false otherwise
    func isDue(on date: Date, withFrequency freq: HabitFrequency) -> Bool {
        guard started(before: date) else {
            return false
        }
        switch freq {
        case .timesPerDay(_):
            return true
        case .specificWeekdays(let days):
            return days.contains(Weekday(date))
        case .timesPerWeek(_, resetDay: let resetDay):
            // Habit due all at once on the reset day, otherwise it would mess with daily percent calculations
            return date.weekdayIndex == resetDay.rawValue
        }
    }
}
