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

    static var startOfWeek: Weekday = .sunday
    
    var id: Int {
        self.rawValue
    }
    
    /// Adjust the index based on the start of the week preference
    /// - Parameter rawIndex: The raw index which should match: M = 0, T = 1, W = 2, T = 3, F = 4, S = 5, S = 6
    /// - Returns: The adjusted index so that the start of the week is index 0
    private static func adjustIndex(_ rawIndex: Int) -> Int {
        return (rawIndex - Weekday.startOfWeek.rawValue + 7) % 7
    }

    var index: Int {
        Weekday.adjustIndex(self.rawValue)
    }
    
    static var orderedCases: [Weekday] {
        return Array(Weekday.allCases[startOfWeek.rawValue...]) +
        Array(Weekday.allCases[..<startOfWeek.rawValue])
    }

    init(_ date: Date) {
        // S = 1, M = 2, T = 3, W = 4, T = 5, F = 6, S = 7
        let weekdayComponent = Cal.component(.weekday, from: date)
        // Convert to
        // M = 0, T = 1, W = 2, T = 3, F = 4, S = 5, S = 6
        let rawIndex = (weekdayComponent - 2 + 7) % 7
        // Convert to adjusted index based on start of week preference
        self.init(rawValue: Weekday.adjustIndex(rawIndex))!
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

    static func < (lhs: Weekday, rhs: Weekday) -> Bool {
        lhs.index < rhs.index
    }

    static func positiveDifference(from a: Weekday, to b: Weekday) -> Int {
        var diff = b.index - a.index
        if diff < 0 {
            diff += 7
        }
        return diff
    }
}
