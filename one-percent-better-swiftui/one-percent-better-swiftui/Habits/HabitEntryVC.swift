//
//  HabitEntryVC.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 12/6/21.
//

import UIKit

// MARK: - HabitEntryVC

class HabitEntryVC: UIViewController, UITableViewDelegate, UITableViewDataSource, TouchedTableViewTouchDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    /// Table View is of type TouchedTableView, which delegates touches
    /// in the table but not a row to this class
    @IBOutlet weak var tableView: TouchedTableView!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // MARK: - Properties
    
    /// The habit to create an entry for
    var habit: Habit!
    
    /// List of trackers which require manual data entry
    var manualTrackers: [Tracker] = []
    
    /// Height of Table View Header
    var tableViewHeaderHeight: CGFloat = 30
    
    /// The habit cell which needs to be updated if creating a new entry from Habit Table VC
    var habitCell: HabitCell?
    
    /// A boolean to open the keyboard and focus on the first number tracker
    /// entry cell when loading the view for the first time
    var firstShowKeyboard: Bool = true
    
    /// The date selected by the date cell
    var selectedDate: Date = Date()
    
    /// The value selected by the completed cell
    var completionStatus: Bool!
    
    /// A boolean indicating whether we are coming from Habit Table VC or Progress VC
    var comingFromHabitTable = false
    
    /// The IndexPath section number for the date field
    var dateSection: Int? {
        return comingFromHabitTable ? nil : 0
    }
    
    /// The IndexPath section number for the completion field
    var completedSection: Int {
        if dateSection == nil {
            return 0
        } else {
            return 1
        }
    }
    
    /// The IndexPath section number for the tracker entries
    var trackerSection: Int {
        completedSection + 1
    }
    
    /// An array IndexPaths (row, section) of all the trackers
    lazy var trackerIndexPaths: [IndexPath] = {
        var indexPaths: [IndexPath] = []
        for i in 0 ..< manualTrackers.count {
            indexPaths.append(IndexPath(row: i, section: trackerSection))
        }
        return indexPaths
    }()
    
    /// The image picker controller used to select photos for image trackers
    var imagePicker = UIImagePickerController()
    
    /// The currently selected image tracker, used to know which tracker to update when selecting a photo
    var selectedImageTracker: ImageTracker?
    
    /// Number dictionary used to store new entries for number trackers
    var numberDict: [NumberTracker:String?] = [:]
    
    /// Image dictionary used to store new entries for image trackers
    var imageDict: [ImageTracker:UIImage?] = [:]
    
    /// Boolean indicating whether the entry has changed compared to what is saved on disk
    var entryIsDifferent: Bool {
        if completionStatus != habit.wasCompleted(on: selectedDate) {
            return true
        } else {
            if completionStatus == false {
                return false
            } else {
                return trackersAreDifferent
            }
        }
    }
    
    /// Boolean indicating whether the tracker entries are different compared to what is saved on disk
    var trackersAreDifferent: Bool {
        for tracker in manualTrackers {
            if let t = tracker as? NumberTracker,
               let numberDictValue = numberDict[t],
               numberDictValue != t.getValue(date: selectedDate) {
                return true
            } else if let t = tracker as? ImageTracker {
                if let origImage = t.getValue(date: selectedDate),
                   let newImage = imageDict[t],
                   !imagesEqual(newImage, origImage) {
                    return true
                }
            }
        }
        return false
    }
    
    // MARK: - Configure
    
    /// Call this method to configure the HabitEntryVC class
    /// - Parameters:
    ///   - habit: The habit to create a new entry for
    ///   - cell: The habit cell if coming from HabitTableVC (optional)
    ///   - completionStatus: Whether to mark the completion cell as completed or not (optional)
    func configure(habit: Habit, cell: HabitCell? = nil, completionStatus: Bool? = nil) {
        self.habit = habit
        self.habitCell = cell
        if let cs = completionStatus {
            self.completionStatus = cs
        } else {
            self.completionStatus = habit.wasCompleted(on: selectedDate)
        }
        
        if habitCell != nil {
            comingFromHabitTable = true
        } else {
            comingFromHabitTable = false
        }
        
        numberDict = [:]
        imageDict = [:]
        
        // Only keep track of manual trackers
        for tracker in habit.trackers {
            if let t = tracker as? Tracker,
               !t.autoTracker {
                manualTrackers.append(t)
            }
        }
        
        // Initialize dictionaries
        for tracker in manualTrackers {
            if let t = tracker as? NumberTracker,
               let value = t.getValue(date: selectedDate) {
                numberDict[t] = value
            } else if let t = tracker as? ImageTracker,
                      let image = t.getValue(date: selectedDate) {
                imageDict[t] = image
            }
        }
    }
    
    // MARK: - View Controller methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.topItem?.title = habit.name
        
        tableView.touchedTableViewDelegate = self
        imagePicker.delegate = self
        
        saveButton.isEnabled = entryIsDifferent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    // MARK: - Segue Methods
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "HabitEntrySave" {
            // If completion status is not selected, mark habit as not completed
            // on the selected day
            if completionStatus == false,
               habit.wasCompleted(on: selectedDate) {
                habit.markNotCompleted(on: selectedDate)
                if let hc = habitCell,
                   Calendar.current.isDate(selectedDate, inSameDayAs: Date()) {
                    hc.updateButton()
                }
                return true
            }
            
            // If entry is different, update the habit with new trackers and perform segue
            if entryIsDifferent {
                for tracker in manualTrackers {
                    if let tracker = tracker as? NumberTracker {
                        // Test if number trackers have changed
                        if numberDict[tracker] != tracker.getValue(date: selectedDate) {
                            if let stringValue = numberDict[tracker],
                               let actualStringValue = stringValue {
                                guard let _ = Double(actualStringValue) else {
                                    let errorAlert = UIAlertController(title: "Value for \(tracker.name) is not a number",
                                                                       message: nil,
                                                                       preferredStyle: .alert)
                                    errorAlert.addAction(UIAlertAction(title: "OK",
                                                                       style: .default,
                                                                       handler: nil))
                                    present(errorAlert, animated: true, completion: nil)
                                    return false
                                }
                                tracker.add(date: selectedDate, value: actualStringValue)
                            } else {
                                tracker.remove(on: selectedDate)
                            }
                        }
                    } else if let t = tracker as? ImageTracker {
                        // Test if image trackers have changed
                        if let newImageOptional = imageDict[t] {
                            if let newImage = newImageOptional {
                                t.add(date: selectedDate, value: newImage)
                            } else {
                                t.remove(on: selectedDate)
                            }
                        }
                    }
                }
                habit.markCompleted(on: selectedDate)
                if let hc = habitCell,
                   Calendar.current.isDate(selectedDate, inSameDayAs: Date()) {
                    hc.updateButton(showAnimation: true)
                }
                return true
            } else {
                return false
            }
        } else if identifier == "HabitEntryCancel" {
            if trackersAreDifferent {
                let alert = UIAlertController(title: "Are you sure you want to cancel?",
                                              message: "You have unsaved trackers",
                                              preferredStyle: .alert)
                
                let yesAction = UIAlertAction(title: "Yes",
                                              style: .default) { [weak self] action in
                    guard let strongSelf = self else { fatalError("can't get strong self") }
                    strongSelf.numberDict = [:]
                    strongSelf.imageDict = [:]
                    strongSelf.performSegue(withIdentifier: "HabitEntryCancel", sender: strongSelf)
                }
                
                let noAction = UIAlertAction(title: "No",
                                                 style: .cancel)
                alert.addAction(yesAction)
                alert.addAction(noAction)
                present(alert, animated: true)
                return false
            } else {
                return true
            }
        } else {
            return true
        }
    }
    
    /// Compare two optional images to see if they are the same
    /// - Parameters:
    ///   - image1: The first image to compare
    ///   - image2: The second image to compare
    /// - Returns: True if images are equal (both nil, or both the same image) and false otherwise
    func imagesEqual(_ image1: UIImage?, _ image2: UIImage?) -> Bool {
        if (image1 == nil && image2 != nil) ||
            (image1 != nil && image2 == nil) {
            return false
        } else if let image1 = image1?.pngData(),
                  let image2 = image2?.pngData(),
                  image1 == image2 {
            return true
        } else {
            return false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HabitEntryDelete" {
            habit.markNotCompleted(on: selectedDate)
            if let hc = habitCell,
               Calendar.current.isDate(selectedDate, inSameDayAs: Date()) {
                hc.updateButton(showAnimation: true)
            }
        }
    }
    
    // MARK: - TableView methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let hasDate = dateSection == nil ? 0 : 1
        let hasCompletion = 1 // always has this section
        let hasTrackers = 1 // always has this section
        return hasDate + hasCompletion + hasTrackers
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == dateSection {
            return 1
        } else if section == completedSection {
            return 1
        } else if section == trackerSection {
            return completionStatus ? manualTrackers.count : 0
        } else {
            fatalError("wrong number of sections")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == dateSection {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UpdateHabitDateCell.self), for: indexPath) as! UpdateHabitDateCell
            cell.updateDateDelegate = self
            return cell
        } else if indexPath.section == completedSection {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UpdateHabitCompletedCell.self), for: indexPath) as! UpdateHabitCompletedCell
            cell.configure(habit: habit, date: selectedDate, completionStatus: completionStatus)
            cell.delegate = self
            return cell
        } else if indexPath.section == trackerSection {
            if let tracker = manualTrackers[indexPath.row] as? NumberTracker {
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NumberTrackerEntryCell.self), for: indexPath) as! NumberTrackerEntryCell
                cell.configure(tracker: tracker, delegate: self, date: selectedDate, value: numberDict[tracker] ?? nil, hasNewValue: numberDict.keys.contains(tracker))
                
                // Only show the keyboard if the first item is a NumberTracker and
                // it's the first time loading this cell
                if indexPath.row == 0 && firstShowKeyboard {
                    firstShowKeyboard = false
                    cell.valueField.becomeFirstResponder()
                }
                return cell
            } else if let tracker = manualTrackers[indexPath.row] as? ImageTracker {
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ImageTrackerEntryCell.self), for: indexPath) as! ImageTrackerEntryCell
                cell.configure(tracker: tracker, cellRow: indexPath.row, date: selectedDate, image: imageDict[tracker] ?? nil, hasNewImage: imageDict.keys.contains(tracker))
                cell.imagePickerDelegate = self
                return cell
            } else {
                fatalError("Unknown tracker")
            }
        } else {
            fatalError("wrong number of sections")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == dateSection {
            return UpdateHabitDateCell.cellHeight
        } else if indexPath.section == completedSection {
            return 44
        } else if indexPath.section == trackerSection {
            if let _ = manualTrackers[indexPath.row] as? NumberTracker {
                return NumberTrackerEntryCell.cellHeight
            } else if let tracker = manualTrackers[indexPath.row] as? ImageTracker {
                if imageDict.keys.contains(tracker) {
                    let newImage = imageDict[tracker]!
                    if newImage == nil {
                       return ImageTrackerEntryCell.defaultCellHeight
                    } else {
                        return ImageTrackerEntryCell.imageCellHeight
                    }
                } else if tracker.getValue(date: selectedDate) != nil {
                    return ImageTrackerEntryCell.imageCellHeight
                } else {
                    return ImageTrackerEntryCell.defaultCellHeight
                }
            }
            return 44
        } else {
            fatalError("wrong number of sections in \(String(describing: self))")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return tableViewHeaderHeight
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if indexPath.section != trackerSection {
            let swipeAction = UISwipeActionsConfiguration(actions: [])
            return swipeAction
        }
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, sourceView, completionHandler) in
            guard let strongSelf = self else {
                fatalError("Unable to get self in HabitEntryVC")
            }
            let tracker = strongSelf.manualTrackers[indexPath.row]
            if let t = tracker as? NumberTracker {
                strongSelf.numberDict.updateValue(nil, forKey: t)
                let cell = tableView.cellForRow(at: indexPath) as! NumberTrackerEntryCell
                cell.deleteEntry()
            } else if let t = tracker as? ImageTracker {
                strongSelf.imageDict.updateValue(nil, forKey: t)
                let cell = tableView.cellForRow(at: indexPath) as! ImageTrackerEntryCell
                cell.deleteEntry()
                strongSelf.tableView.reloadData()
            }
            strongSelf.saveButton.isEnabled = strongSelf.entryIsDifferent
            completionHandler(true)
        }
        let swipeAction = UISwipeActionsConfiguration(actions: [delete])
        swipeAction.performsFirstActionWithFullSwipe = false // Disables full swipe to delete in one motion
        return swipeAction
    }
    
    // MARK: - Keyboard Methods
    
    func touchesBeganInTableView(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

// MARK: - UpdateDateForEditEntryCells

extension HabitEntryVC: UpdateDateForEditEntryCells {
    func updateDate(date: Date) {
        selectedDate = date
        completionStatus = habit.wasCompleted(on: selectedDate)
        imageDict = [:]
        numberDict = [:]
        saveButton.isEnabled = false
        tableView.reloadData()
    }
}

// MARK: - ReloadEditEntryCells

extension HabitEntryVC: ReloadEditEntryCells {
    func reloadTable(completionStatus: Bool) {
        self.completionStatus = completionStatus
        saveButton.isEnabled = entryIsDifferent
        
        if completionStatus {
            tableView.insertRows(at: trackerIndexPaths, with: .middle)
        } else {
            tableView.deleteRows(at: trackerIndexPaths, with: .middle)
            view.endEditing(true)
            firstShowKeyboard = true
        }
    }
}

// MARK: - NumberFieldDelegate

protocol NumberFieldDelegate {
    func updateNumberField(for tracker: NumberTracker, value: String?)
}

extension HabitEntryVC: NumberFieldDelegate {
    func updateNumberField(for tracker: NumberTracker, value: String?) {
        let convertNilValue = value == "" ? nil : value
        numberDict.updateValue(convertNilValue, forKey: tracker)
        saveButton.isEnabled = entryIsDifferent
    }
}


// MARK: - UIImagePickerControllerDelegate

protocol ImagePickerDelegate {
    func imageButtonSelected(for tracker: ImageTracker)
}

extension HabitEntryVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate, ImagePickerDelegate {
    
    func imageButtonSelected(for tracker: ImageTracker) {
        selectedImageTracker = tracker
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: { () -> Void in
            
        })
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        
        imageDict[selectedImageTracker!] = image
        saveButton.isEnabled = entryIsDifferent
        tableView.reloadData()
    }
}


// MARK: - TouchedTableView

protocol TouchedTableViewTouchDelegate: AnyObject {
    func touchesBeganInTableView(_ touches: Set<UITouch>, with event: UIEvent?)
}

class TouchedTableView: UITableView
{
    var touchedTableViewDelegate: TouchedTableViewTouchDelegate?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchedTableViewDelegate?.touchesBeganInTableView(touches, with: event)
    }

}
