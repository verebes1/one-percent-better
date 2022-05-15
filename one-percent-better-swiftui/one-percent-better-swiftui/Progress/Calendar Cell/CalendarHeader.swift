//
//  CalendarHeader.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 11/15/21.
//

/*
import UIKit

class CalendarHeader: UICollectionReusableView {
    static let identifier = "CalendarHeader"
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var previousMonthButton: UIButton!
    @IBOutlet weak var nextMonthButton: UIButton!
    
    public var calendarCalculatorDelegate: UpdateCalendarMonth!
    public var collectionViewDelegate: CalendarCollectionViewDelegate!
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMM y")
        return dateFormatter
    }()
    
    func configure(calendarCalculator: CalendarCalculator) {
        calendarCalculatorDelegate = calendarCalculator
        let baseDate = calendarCalculator.getBaseDate()
        monthLabel.text = dateFormatter.string(from: baseDate)
    }
    
    @IBAction func nextMonthButtonPressed(_ sender: Any) {
        let baseDate = calendarCalculatorDelegate.nextMonth()
        monthLabel.text = dateFormatter.string(from: baseDate)
        collectionViewDelegate.reloadCalendar()
    }
    
    @IBAction func previousMonthButtonPressed(_ sender: Any) {
        let baseDate = calendarCalculatorDelegate.previousMonth()
        monthLabel.text = dateFormatter.string(from: baseDate)
        collectionViewDelegate.reloadCalendar()
    }
}

*/
