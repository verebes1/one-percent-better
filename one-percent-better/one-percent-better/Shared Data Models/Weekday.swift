//
//  Weekday.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 8/24/23.
//

import Foundation

enum Weekday: Int, CustomStringConvertible, CaseIterable, Identifiable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    /// The user's preference for the start of the week
    static var startOfWeek: Self {
        StartOfWeekModel.shared.startOfWeek
    }
    
    /// Calculate the positive difference between two weekdays
    /// - Parameter a: First weekday
    /// - Parameter b: Second weekday
    static func positiveDifference(from a: Weekday, to b: Weekday) -> Int {
        return (b.rawValue - a.rawValue + 7) % 7
    }
    
    
    /// Get the date of the most recent weekday which occured strictly before a date
    /// - Parameters:
    ///   - weekday: The desired weekday
    ///   - date: The date
    /// - Returns: The most recent date which has that weekday before the date
    static func mostRecentDate(on weekday: Weekday, before date: Date) -> Date {
        let diff = positiveDifference(from: weekday, to: Weekday(date))
        return Cal.add(days: -diff, to: date)
    }
    
    /// The day index, adjusted for the user's start of week preference
    var index: Int {
        Self.positiveDifference(from: Weekday.startOfWeek, to: self)
    }
    
    /// The weekday given an index, adjusted for the user's preferred start of the week
    static func weekday(for index: Int) -> Weekday {
        let startRawValue = startOfWeek.rawValue
        let weekdayRawValue = (startRawValue + index) % 7
        return Weekday(rawValue: weekdayRawValue)!
    }

    init(_ date: Date) {
        // S = 1, M = 2, T = 3, W = 4, T = 5, F = 6, S = 7
        let weekdayComponent = Cal.component(.weekday, from: date)
        // Convert to M = 0, T = 1, W = 2, T = 3, F = 4, S = 5, S = 6
        let rawValue = (weekdayComponent - 2 + 7) % 7
        self.init(rawValue: rawValue)!
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

    var letter: String {
        switch self {
        case .monday: return "M"
        case .tuesday: return "T"
        case .wednesday: return "W"
        case .thursday: return "T"
        case .friday: return "F"
        case .saturday: return "S"
        case .sunday: return "S"
        }
    }
    
    var threeLetter: String {
        switch self {
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        case .sunday: return "Sun"
        }
    }
    
    // MARK: Identifiable
    
    var id: Int { self.rawValue }
    
    // MARK: Case Iterable
    
    static var orderedCases: [Weekday] {
        return Array(Weekday.allCases[startOfWeek.rawValue...]) +
        Array(Weekday.allCases[..<startOfWeek.rawValue])
    }
}
