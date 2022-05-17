//
//  ToggleCell.swift
//  mo-ikai
//
//  Created by Timothy Gan on 3/28/21.
//

import UIKit
import CoreHaptics

class HabitCell: UITableViewCell {

//    static let identifier = "HabitCell"
    static let rowHeight: CGFloat = 55
    
    @IBOutlet weak var checkImage: UIImageView!
    @IBOutlet weak var habitName: UILabel!
    
    @IBOutlet var streakLabel: UILabel!
    @IBOutlet var rightIndicatorButton: UIButton!
    
    private var habit: Habit!
    var delegate: HabitCellDelegator!
    
    // Configuration for the completion circle on the left
    let checkedImage = UIImage(systemName: "checkmark.circle.fill")
    let uncheckedImage = UIImage(systemName: "circle")
    
    func configure(habit: Habit) {
        self.habit = habit
        habitName.text = habit.name
        updateButton(showAnimation: false)
        updateStreakLabel()
    }
    
    // Update the checkmark button
    func updateButton(showAnimation: Bool = false) {
        if habit.wasCompleted(on: Date()) {
            checkImage.image = checkedImage
            checkImage.tintColor = Style.UIKitGreen
            
            if showAnimation {
                let animation = CAKeyframeAnimation(keyPath: "transform.scale")
                animation.values = [1.0, 1.3, 1.0]
                animation.keyTimes = [0, 0.5, 1]
                animation.duration = 0.2
                animation.repeatCount = 1
                self.checkImage.layer.add(animation, forKey: nil)
                
//                if AppDelegate.supportsHaptics {
//                    delegate.playHaptic()
//                }
            }
        } else {
            checkImage.image = uncheckedImage
            checkImage.tintColor = Style.lightGray
        }
        
        updateStreakLabel()
    }
    
    func updateStreakLabel() {
        if habit.streak > 0 {
            streakLabel.text = "\(habit.streak) day streak"
            streakLabel.textColor = Style.UIKitGreen
        } else if habit.daysCompleted.isEmpty {
            streakLabel.text = "Never done"
            streakLabel.textColor = Style.lightGray
        } else {
            let lastCompletedDay = habit.daysCompleted[habit.daysCompleted.count - 1]
            let difference = Calendar.current.numberOfDaysBetween(lastCompletedDay, and: Date()) - 2
            let dayText = difference == 1 ? "day" : "days"
            streakLabel.text = "Not done in \(difference) \(dayText)"
            streakLabel.textColor = Style.red
        }
    }
    
    @IBAction func checkmarkButtonPressed(_ sender: Any?) {
        if habit.manualTrackers.count == 0 {
            if habit.wasCompleted(on: Date()) {
                habit.markNotCompleted(on: Date())
            } else {
                habit.markCompleted(on: Date())
            }
            updateButton(showAnimation: true)
        } else {
            delegate.performNewEntrySegue(habit: habit)
        }
    }
}
