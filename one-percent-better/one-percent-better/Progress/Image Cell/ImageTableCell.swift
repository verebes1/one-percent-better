//
//  ImageTableCell.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 12/16/21.
//

import Foundation
import UIKit


class ImageTableCell: UITableViewCell {
    
    @IBOutlet weak var trackerNameLabel: UILabel!
    @IBOutlet weak var viewAllButton: UIButton!
    
    @IBOutlet weak var beforeImageView: UIImageView!
    @IBOutlet weak var afterImageView: UIImageView!
    
    @IBOutlet weak var beforeDateLabel: UILabel!
    @IBOutlet weak var afterDateLabel: UILabel!
    
    @IBOutlet weak var dateRangeSlider: UISlider!
    
    static let cellHeight: CGFloat = 350
    var tracker: ImageTracker!
    var viewAllImagesDelegate: ViewAllImages!
    
    let defaultImage = UIImage(systemName: "photo.on.rectangle")
    var colorTheme: UIColor = .systemRed
    
    func configure(tracker: ImageTracker, viewAllImagesDelegate: ViewAllImages) {
        self.tracker = tracker
        self.viewAllImagesDelegate = viewAllImagesDelegate
        trackerNameLabel.text = tracker.name
        
        if tracker.dates.isEmpty {
            beforeImageView.image = defaultImage
            afterImageView.image = defaultImage
            
            beforeDateLabel.text = ""
            afterDateLabel.text = ""
        } else {
            let firstDate = tracker.dates.first!
            beforeImageView.image = tracker.getValue(date: firstDate)
            beforeDateLabel.text = firstDate.monthAndDay()
            
            let lastDate = tracker.dates.last!
            if firstDate != lastDate {
                afterImageView.image = tracker.getValue(date: lastDate)
                afterDateLabel.text = lastDate.monthAndDay()
            } else {
                afterImageView.image = defaultImage
                afterDateLabel.text = ""
            }
        }
        
        dateRangeSlider.value = 1
    }
    
    @IBAction func dateRangeChanged(_ sender: Any) {
        
        guard let firstDate = tracker.dates.first,
              let lastDate = tracker.dates.last
        else {
            return
        }
        
        // Number of days between first image date and last image date
        let numDaysBetween = Calendar.current.numberOfDaysBetween(firstDate, and: lastDate)
        // Multiply by slider value (0-1) to get date between which matches slider
        let numDaysRatio = dateRangeSlider.value * Float(numDaysBetween)
        // Convert to int and round up to next day
        let numDaysInt = Int(round(numDaysRatio))
        var sliderDay = Calendar.current.date(byAdding: .day, value: numDaysInt, to: firstDate)!
        
        for _ in 0 ..< numDaysInt {
            if tracker.dates.contains(where: { Calendar.current.isDate($0, inSameDayAs: sliderDay) } ) {
                let image = tracker.getValue(date: sliderDay)
                afterImageView.image = image
                afterDateLabel.text = sliderDay.monthAndDay()
                break
            }
            sliderDay = Calendar.current.date(byAdding: .day, value: -1, to: sliderDay)!
        }
    }
    
    
    @IBAction func viewAllImagesPressed(_ sender: Any) {
        viewAllImagesDelegate.viewAllImages(for: tracker)
    }
    
}
