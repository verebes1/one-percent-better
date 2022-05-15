//
//  HabitEntryCells.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 12/16/21.
//

import UIKit

// MARK: - NumberTrackerEntryCell

class NumberTrackerEntryCell: UITableViewCell, UITextFieldDelegate {
    
    static let cellHeight: CGFloat = 44
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueField: UITextField!
    @IBOutlet weak var unitsLabel: UILabel!
    
    var tracker: NumberTracker!
    var numberFieldDelegate: NumberFieldDelegate!
    var cellRow: Int!

    func configure(tracker: NumberTracker, delegate: NumberFieldDelegate, date: Date, value: String?, hasNewValue: Bool) {
        self.tracker = tracker
        self.numberFieldDelegate = delegate
        self.nameLabel.text = tracker.name
        self.unitsLabel.text = ""
        
        valueField.delegate = self
        if hasNewValue {
            if let v = value {
                valueField.text = v
            } else {
                valueField.text = ""
            }
        } else {
            if let value = tracker.getValue(date: date) {
                valueField.text = String(value)
            } else {
                valueField.text = ""
            }
        }
    }
    
    func deleteEntry() {
        valueField.text = ""
    }
    
    @IBAction func numberFieldEdited(_ sender: Any) {
        numberFieldDelegate.updateNumberField(for: tracker, value: valueField.text)
    }
}

// MARK: - ImageTrackerEntryCell

class ImageTrackerEntryCell: UITableViewCell {
    
    @IBOutlet weak var imageTrackerName: UILabel!
    @IBOutlet weak var trackerImage: UIImageView!
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageButtonWidthConstraint: NSLayoutConstraint!
    
    static let defaultCellHeight: CGFloat = 44
    let defaultImage = UIImage(systemName: "photo.on.rectangle")
    static let imageCellHeight: CGFloat = 80
    var buttonWidth: CGFloat!
    var tracker: ImageTracker!
    var imagePickerDelegate: ImagePickerDelegate!
    var cellRow: Int!
    
    func configure(tracker: ImageTracker, cellRow: Int, date: Date, image: UIImage?, hasNewImage: Bool) {
        self.tracker = tracker
        imageTrackerName.text = tracker.name
        self.cellRow = cellRow
        
        if hasNewImage {
            if let im = image {
                trackerImage.image = im
                imageViewWidthConstraint.constant = 48
                buttonWidth = 88
            } else {
                trackerImage.image = defaultImage
                imageViewWidthConstraint.constant = 28
                buttonWidth = 68
            }
        } else {
            if let trackerHasImage = tracker.getValue(date: date) {
                trackerImage.image = trackerHasImage
                imageViewWidthConstraint.constant = 48
                buttonWidth = 88
            } else {
                trackerImage.image = defaultImage
                imageViewWidthConstraint.constant = 28
                buttonWidth = 68
            }
        }
        imageButtonWidthConstraint.constant = buttonWidth
    }
    
    func deleteEntry() {
        trackerImage.image = defaultImage
        imageViewWidthConstraint.constant = 28
        buttonWidth = 68
    }
    
    @IBAction func imageButtonSelected(_ sender: Any) {
        imagePickerDelegate.imageButtonSelected(for: tracker)
    }
}

// MARK: - UpdateHabitDateCell

protocol UpdateDateForEditEntryCells {
    func updateDate(date: Date)
}

class UpdateHabitDateCell: UITableViewCell {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    static let cellHeight: CGFloat = 50
    var updateDateDelegate: UpdateDateForEditEntryCells!
    
    @IBAction func datePickerChanged(_ sender: Any) {
        updateDateDelegate.updateDate(date: datePicker.date)
    }
}

// MARK: - UpdateHabitCompletedCell

protocol ReloadEditEntryCells {
    func reloadTable(completionStatus: Bool)
}

class UpdateHabitCompletedCell: UITableViewCell {
    
    @IBOutlet weak var checkImage: UIImageView!
    
    var habit: Habit!
    var date: Date!
    var delegate: ReloadEditEntryCells!
    @IBOutlet weak var markAsCompletedLabel: UILabel!
    
    // The state of the checkmark button
    // Green checkmark is true, grey circle is false
    var imageIsCheckmark = false
    let checkedImage = UIImage(systemName: "checkmark.circle.fill")
    let uncheckedImage = UIImage(systemName: "circle")
    
    func configure(habit: Habit, date: Date, completionStatus: Bool) {
        self.habit = habit
        self.date = date
        imageIsCheckmark = completionStatus
        updateLabel(completionStatus: completionStatus)
        updateCheckmark(checked: completionStatus)
    }
    
    func updateLabel(completionStatus: Bool) {
        if !completionStatus {
            markAsCompletedLabel.text = "Uncompleted"
        } else {
            markAsCompletedLabel.text = "Completed"
        }
    }
    
    func updateCheckmark(checked: Bool, animate: Bool = false) {
        if !checked {
            checkImage.image = uncheckedImage
            checkImage.tintColor = Style.lightGray
        } else {
            checkImage.image = checkedImage
            checkImage.tintColor = .systemGreen
            if animate {
                let animation = CAKeyframeAnimation(keyPath: "transform.scale")
                animation.values = [1.0, 1.3, 1.0]
                animation.keyTimes = [0, 0.5, 1]
                animation.duration = 0.2
                animation.repeatCount = 1
                self.checkImage.layer.add(animation, forKey: nil)
            }
        }
    }
    
    @IBAction func completedButtonPressed(_ sender: Any) {
        imageIsCheckmark = !imageIsCheckmark
        updateLabel(completionStatus: imageIsCheckmark)
        updateCheckmark(checked: imageIsCheckmark, animate: true)
        delegate.reloadTable(completionStatus: imageIsCheckmark)
    }
}
