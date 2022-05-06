//
//  CreateHabitTimeVC.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 11/30/21.
//

import UIKit

class CreateHabitTimeSetCell: UITableViewCell {
    
    static var identifier: String {
        String(describing: self)
    }
    @IBOutlet weak var datePicker: UIDatePicker!
    
}

class CreateHabitTimeRemindCell: UITableViewCell {
    
    static var identifier: String {
        String(describing: self)
    }
    @IBOutlet weak var `switch`: UISwitch!
    
}

class CreateHabitTimeVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    var numCells = 2
    var cellHeight: CGFloat = 50
    var habit: Habit!
    var delegate: UpdateHabitWhileCreating!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check
        guard let _ = habit else {
            fatalError("habit should not be nil")
        }
        
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        tableViewHeightConstraint.constant = CGFloat(numCells) * cellHeight
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let delegate = delegate else {
            fatalError("delegate should have been set up")
        }
        
        if self.isMovingFromParent {
            delegate.update(habit: habit)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createTimeSegue",
           let destination = segue.destination as? CreateHabitTrackerVC {
            
            guard let timeCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CreateHabitTimeSetCell else {
                fatalError("Can't get cell in \(String(describing: self)))")
            }
            
            habit.notificationTime = timeCell.datePicker.date
                
            // Get cell
            guard let switchCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? CreateHabitTimeRemindCell else {
                fatalError("Can't get cell in \(String(describing: self)))")
            }
            
            if switchCell.switch.isOn {
                if habit.notificationTime != nil {
                    NotificationPopoverVC.deleteNotification(for: habit)
                }
                NotificationPopoverVC.createNotification(for: habit)
            }
            
            destination.habit = habit
            destination.delegate = self
        } else if segue.identifier == "createTimeSkipSegue",
                  let destination = segue.destination as? CreateHabitTrackerVC {
            destination.habit = habit
            destination.delegate = self
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: CreateHabitTimeSetCell.identifier, for: indexPath) as! CreateHabitTimeSetCell
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: CreateHabitTimeRemindCell.identifier, for: indexPath) as! CreateHabitTimeRemindCell
        default:
            fatalError("wrong number of cells in CreateHabitTimeVC")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
}

// MARK: - Update habit
extension CreateHabitTimeVC: UpdateHabitWhileCreating {
    func update(habit: Habit) {
        self.habit = habit
    }
}
