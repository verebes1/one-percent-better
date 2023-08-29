//
//  Weekday.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 8/24/23.
//

import Foundation

enum Weekday: Int, CustomStringConvertible, Comparable, CaseIterable, Identifiable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    /// The chosen user preference for the start of the week
    static var startOfWeek: Weekday = .friday
    
    /// Calculate the positive difference between two weekdays
    /// - Parameter a: First weekday
    /// - Parameter b: Second weekday
    static func positiveDifference(from a: Weekday, to b: Weekday) -> Int {
        return (b.rawValue - a.rawValue + 7) % 7
    }
    
    /// The day index, adjusted for the user's start of week preference
    var index: Int {
        Self.positiveDifference(from: Self.startOfWeek, to: self)
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
    
    // MARK: Comparable

    static func < (lhs: Weekday, rhs: Weekday) -> Bool {
        lhs.index < rhs.index
    }
    
    // MARK: Identifiable
    
    var id: Int { self.rawValue }
    
    // MARK: Case Iterable
    
    static var orderedCases: [Weekday] {
        return Array(Weekday.allCases[startOfWeek.rawValue...]) +
        Array(Weekday.allCases[..<startOfWeek.rawValue])
    }
}
