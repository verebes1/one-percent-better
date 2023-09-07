//
//  CalenderView.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 11/11/21.
//

import Foundation
import Combine

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
        Cal.range(of: .weekOfMonth, in: .month, for: baseDate)?.count ?? 0
    }
    
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
        let offsetDate = Cal.date(
            byAdding: .month,
            value: -offset,
            to: Date()
        )!
        return offsetDate
    }
    
    enum CalendarDataError: Error {
        case metadataGeneration
    }
    
    /// The user preference for the start of the week
    var startOfWeek: Weekday
    
    private var cancelBag: Set<AnyCancellable> = []
    
    init(habit: Habit, sowm: StartOfWeekModel) {
        self.habit = habit
        self.baseDate = Date()
        self.startOfWeek = sowm.startOfWeek
        self.currentPage = numMonthsSinceStart - 1
        
        // Subscribe to start of week from StartOfWeekModel
        sowm.$startOfWeek.sink { newWeekday in
            self.startOfWeek = newWeekday
        }
        .store(in: &cancelBag)
    }
    
    
    // MARK: - Day Generation
    func monthMetadata(for baseDate: Date) throws -> MonthMetadata {
        guard
            let numberOfDaysInMonth = Cal.range(
                of: .day,
                in: .month,
                for: baseDate)?.count,
            let firstDayOfMonth = Cal.date(
                from: Cal.dateComponents([.year, .month], from: baseDate))
        else {
            throw CalendarDataError.metadataGeneration
        }
        
        // Needs to be 1 ... 7 instead of 0 ... 6
        let firstDayWeekday = Weekday(firstDayOfMonth).index(startOfWeek) + 1
        
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
        let date = Cal.date(byAdding: .day, value: dayOffset, to: baseDate) ?? baseDate
        
        return Day(
            date: date,
            isWithinDisplayedMonth: isWithinDisplayedMonth
        )
    }
    
    func generateStartOfNextMonth(using firstDayOfDisplayedMonth: Date) -> [Day] {
        guard
            let lastDayInMonth = Cal.date(
                byAdding: DateComponents(month: 1, day: -1),
                to: firstDayOfDisplayedMonth)
        else {
            return []
        }
        
        let additionalDays = 7 - Cal.component(.weekday, from: lastDayInMonth)
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
        let newDate = Cal.date(
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
        
        let numberOfDaysInMonth = Cal.range(
            of: .day,
            in: .month,
            for: currentBaseDate)!.count
        
        return (completed, numberOfDaysInMonth)
    }
    
    var rowSpacing: CGFloat {
        guard let monthMetadata = try? monthMetadata(for: currentBaseDate) else { return 2 }
        let firstDay = monthMetadata.firstDay
        let numDays = monthMetadata.numberOfDays
        
        // "Fill" in the days before the first day, then divide by 7
        // to get the number of weeks in this month based on start of week preference
        let additionalDays = Weekday(firstDay).index(startOfWeek)
        
        let total = numDays + additionalDays
        let numWeeks = Int((Double(total) / 7).rounded(.awayFromZero))
        
        if numWeeks == 6 {
            return 2
        } else if numWeeks == 5 {
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
