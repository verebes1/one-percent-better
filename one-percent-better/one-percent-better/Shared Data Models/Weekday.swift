//
//  Weekday.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 8/24/23.
//

import Foundation

enum Weekday: Int, CustomStringConvertible, Comparable, CaseIterable {
    case monday = 0
    case tuesday = 1
    case wednesday = 2
    case thursday = 3
    case friday = 4
    case saturday = 5
    case sunday = 6
    
    init(_ date: Date) {
        // S = 1, M = 2, T = 3, W = 4, T = 5, F = 6, S = 7
        var weekdayComponent = Cal.component(.weekday, from: date)
        
        // Convert to M = 0, T = 1, W = 2, T = 3, F = 4, S = 5, S = 6
        weekdayComponent = (weekdayComponent - 2 + 7) % 7
        self.init(rawValue: weekdayComponent)!
    }
    
    init(_ weekdayInt: Int) {
        if weekdayInt < 0 || weekdayInt > 6 {
            assertionFailure("Creating a Weekday with a weekdayInt out of range: \(weekdayInt)")
        }
        self.init(rawValue: weekdayInt)!
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
        return lhs.rawValue < rhs.rawValue
    }
    
    static func positiveDifference(from a: Weekday, to b: Weekday) -> Int {
        var diff = b.rawValue - a.rawValue
        if diff < 0 {
            diff += 7
        }
        return diff
    }
}
