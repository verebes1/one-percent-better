//
//  CalenderView.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 11/11/21.
//

import UIKit

struct MonthMetadata {
    let numberOfDays: Int
    let firstDay: Date
    let firstDayWeekday: Int
}

struct Day {
    let date: Date
    let isWithinDisplayedMonth: Bool
    
    var dayNumber: String {
        date.day()
    }
}

// MARK: - Calendar Calculator

class CalendarModel: ObservableObject {
    
    private var habit: Habit
    
    @Published var currentPage: Int = 0
    
    /// The month this date is in is the month which gets represented
    public var baseDate: Date! {
        didSet {
            days = generateDaysInMonth(for: baseDate)
        }
    }
    
    /// An array of Day objects for this month, based on the baseDate.
    /// Includes the days before and after this month to create a grid of days
    public lazy var days: [Day] = generateDaysInMonth(for: baseDate)
    
    /// The number of weeks in this month. Lowest is 4 (leap year) and highest is 6
    private var numberOfWeeksInBaseDate: Int {
        calendar.range(of: .weekOfMonth, in: .month, for: baseDate)?.count ?? 0
    }
    
    /// The calendar all the calculations are made from
    private let calendar = Calendar(identifier: .gregorian)
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter
    }()
    
    /// Date formatter for the month year label at the top of the calendar
    public var headerFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMM y")
        return dateFormatter
    }()
    
    var headerMonth: String {
        return headerFormatter.string(from: currentBaseDate)
    }
    
    var currentBaseDate: Date {
        let offset = numMonthsSinceStart - 1 - currentPage
        let offsetDate = self.calendar.date(
            byAdding: .month,
            value: -offset,
            to: Date()
        )!
        return offsetDate
    }
    
    enum CalendarDataError: Error {
        case metadataGeneration
    }
    
    init(habit: Habit) {
        self.habit = habit
        self.baseDate = Date()
        self.currentPage = numMonthsSinceStart - 1
    }
    
    
    // MARK: - Day Generation
    func monthMetadata(for baseDate: Date) throws -> MonthMetadata {
        guard
            let numberOfDaysInMonth = calendar.range(
                of: .day,
                in: .month,
                for: baseDate)?.count,
            let firstDayOfMonth = calendar.date(
                from: calendar.dateComponents([.year, .month], from: baseDate))
        else {
            throw CalendarDataError.metadataGeneration
        }
        
        let firstDayWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        return MonthMetadata(
            numberOfDays: numberOfDaysInMonth,
            firstDay: firstDayOfMonth,
            firstDayWeekday: firstDayWeekday)
    }
    
    func generateDaysInMonth(for baseDate: Date) -> [Day] {
        guard let metadata = try? monthMetadata(for: baseDate) else {
            preconditionFailure("An error occurred when generating the metadata for \(baseDate)")
        }
        
        let numberOfDaysInMonth = metadata.numberOfDays
        let offsetInInitialRow = metadata.firstDayWeekday
        let firstDayOfMonth = metadata.firstDay
        
        var days: [Day] = (1..<(numberOfDaysInMonth + offsetInInitialRow))
            .map { day in
                let isWithinDisplayedMonth = day >= offsetInInitialRow
                let dayOffset = isWithinDisplayedMonth ? day - offsetInInitialRow : -(offsetInInitialRow - day)
                
                let dayToAdd = generateDay(offsetBy: dayOffset, for: firstDayOfMonth,
                                           isWithinDisplayedMonth: isWithinDisplayedMonth)
                
                return dayToAdd
            }
        
        days += generateStartOfNextMonth(using: firstDayOfMonth)
        
        return days
    }
    
    func generateDay(offsetBy dayOffset: Int, for baseDate: Date, isWithinDisplayedMonth: Bool) -> Day {
        let date = calendar.date(byAdding: .day, value: dayOffset, to: baseDate) ?? baseDate
        
        return Day(
            date: date,
            isWithinDisplayedMonth: isWithinDisplayedMonth
        )
    }
    
    func generateStartOfNextMonth(using firstDayOfDisplayedMonth: Date) -> [Day] {
        guard
            let lastDayInMonth = calendar.date(
                byAdding: DateComponents(month: 1, day: -1),
                to: firstDayOfDisplayedMonth)
        else {
            return []
        }
        
        let additionalDays = 7 - calendar.component(.weekday, from: lastDayInMonth)
        guard additionalDays > 0 else {
            return []
        }
        
        let days: [Day] = (1...additionalDays).map {
            generateDay(
                offsetBy: $0,
                for: lastDayInMonth,
                isWithinDisplayedMonth: false)
        }
        
        return days
    }
    
    func backXMonths(x: Int) -> [Day] {
        let newDate = self.calendar.date(
            byAdding: .month,
            value: -x,
            to: Date()
        ) ?? self.baseDate
        return generateDaysInMonth(for: newDate!)
    }
    
    var numCompleted: (Int, Int) {
        let days = generateDaysInMonth(for: currentBaseDate)
        
        var completed = 0
        for day in days {
            if !day.isWithinDisplayedMonth { continue }
            if habit.wasCompleted(on: day.date) {
                completed += 1
            }
        }
        
        let numberOfDaysInMonth = calendar.range(
            of: .day,
            in: .month,
            for: currentBaseDate)!.count
        
        return (completed, numberOfDaysInMonth)
    }
    
    var rowSpacing: CGFloat {
        let num = calendar.range(of: .weekOfMonth, in: .month, for: currentBaseDate)?.count ?? 0
        if num == 6 {
            return 2
        } else if num == 5 {
            return 10
        } else {
            return 20
        }
    }
    
    /// The number of months since the startDate of this habit
    public var numMonthsSinceStart: Int {
        let startMonth = Cal.date(from: Cal.dateComponents([.year, .month], from: habit.startDate))!
        let endMonth = Cal.date(from: Cal.dateComponents([.year, .month], from: Date()))!
        let component = Cal.dateComponents([.month], from: startMonth, to: endMonth)
        let numMonths = component.month! + 1
        return numMonths
    }
}
