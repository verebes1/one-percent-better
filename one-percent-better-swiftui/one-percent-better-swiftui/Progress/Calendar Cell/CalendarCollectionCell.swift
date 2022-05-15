//
//  CalendarCollectionCell.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 11/15/21.
//

import UIKit

class CalendarCollectionCell: UICollectionViewCell {
    static let identifier = "CalendarCollectionCell"
    @IBOutlet weak var cellImageView: UIImageView!
    
    let checkmark = UIImage(systemName: "checkmark.circle.fill")
    let circleFill = UIImage(systemName: "circle.fill")
    let circle = UIImage(systemName: "circle")
    
    func configure(day: Day, habit: Habit) {
        if Calendar.current.isDateInToday(day.date) {
            if habit.wasCompleted(on: day.date) {
                cellImageView.image = checkmark
                cellImageView.tintColor = .systemGreen
            } else {
                cellImageView.image = circle
                cellImageView.tintColor = .systemGray3
            }
        } else {
            cellImageView.image = circleFill
            if habit.wasCompleted(on: day.date) {
                cellImageView.tintColor = .systemGreen
            } else {
                cellImageView.tintColor = .systemGray3
            }
        }
        
        if !day.isWithinDisplayedMonth {
            cellImageView.alpha = 0.2
        }
    }
    
    override func prepareForReuse() {
        cellImageView.alpha = 1
    }
}


