//
//  Date+Extensions.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 9/7/23.
//

import Foundation

extension Date {
    var localDate: String {
        description(with: .current)
    }
    
    func get(_ components: Calendar.Component..., calendar: Calendar = Cal) -> DateComponents {
        calendar.dateComponents(Set(components), from: self)
    }
    
    func get(_ component: Calendar.Component, calendar: Calendar = Cal) -> Int {
        calendar.component(component, from: self)
    }
    
    func monthAndDay() -> String {
        let components = self.get(.day, .month)
        return "\(components.month!)/\(components.day!)"
    }
    
    func day() -> String {
        let components = self.get(.day, .month)
        return "\(components.day!)"
    }
    
    var startOfDay: Date {
        Cal.startOfDay(for: self)
    }
    
    func weekdayIndex(_ startOfWeek: Weekday) -> Int {
        Weekday(self).index(startOfWeek)
    }
}

extension Int {
    /// If this integer representing a year (ex. 2023) is a leap year or not
    var isLeapYear: Bool {
        (self % 4 == 0 && self % 100 != 0) || self % 400 == 0
    }
}
