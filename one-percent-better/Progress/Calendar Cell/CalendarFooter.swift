//
//  CalendarFooter.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 11/15/21.
//

import UIKit

class CalendarFooter: UICollectionReusableView {
    static let identifier = "CalendarFooter"
    
    @IBOutlet weak var numDaysLabel: UILabel!
    
    func configure(baseDate: Date, days: [Day], habit: Habit) {
        
        let numberOfDaysInMonth = Calendar.current.range(
            of: .day,
            in: .month,
            for: baseDate)?.count
        
        var daysSoFar = 0
        var daysCompleted = 0
        for day in days {
            if !day.isWithinDisplayedMonth {
                continue
            }
            daysSoFar += 1
            if habit.wasCompleted(on: day.date) {
                daysCompleted += 1
            }
            if Calendar.current.isDateInToday(day.date) {
                break
            }
        }
        
        var text = "\(daysCompleted) of \(daysSoFar) days"
        if daysSoFar != numberOfDaysInMonth {
            text += " so far"
        }
        
        numDaysLabel.text = text
    }
}
