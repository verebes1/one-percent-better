//
//  CreateHabitTrackerVC.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 11/30/21.
//

import UIKit

class CreateHabitNewTrackerCell: UITableViewCell {
    
    static var identifier: String {
        String(describing: self)
    }
    static let cellHeight: CGFloat = 50
    
}

class CreateHabitTrackerVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Variables
    
    var numCells = 1
    var habit: Habit!
    var delegate: UpdateHabitWhileCreating!
    var trackers: [Tracker] = []
    
    var context = CoreDataManager.shared.mainContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
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
        if segue.identifier == "unwindFinishCreatingHabit" {
            for tracker in trackers {
                habit.addToTrackers(tracker)
            }
            
            // Auto trackers
            let it = ImprovementTracker(context: context, habit: habit)
            habit.addToTrackers(it)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return numCells
        } else if section == 1 {
            return trackers.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return ""
        } else {
            return trackers.isEmpty ? "" : "Trackers"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return 30
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CreateHabitNewTrackerCell.identifier, for: indexPath) as! CreateHabitNewTrackerCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CreateHabitTrackerCell", for: indexPath)
            let tracker = trackers[indexPath.row]
            var content = cell.defaultContentConfiguration()
            content.text = tracker.name
            content.secondaryText = tracker.toString()
            cell.contentConfiguration = content
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return CreateHabitNewTrackerCell.cellHeight
        } else {
            return 50
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            presentTrackerOptions()
        }
    }
    
    func presentTrackerOptions() {
        let controller = UIAlertController(
            title: "Select Type of Data to Track",
            message: nil,
            preferredStyle: .actionSheet)
        
        let number = UIAlertAction(title: "Number", style: .default,
                                   handler: {_ in self.addName(type: "Number")})
        let image = UIAlertAction(title: "Image", style: .default,
                                  handler: {_ in self.addName(type: "Image")})
        let cancel = UIAlertAction(title: "Cancel", style: .cancel,
                                   handler: {_ in})
        
        controller.addAction(number)
        controller.addAction(image)
        controller.addAction(cancel)
        present(controller, animated: true, completion: nil)
    }
    
    func addName(type: String) {
        let alert = UIAlertController(title: "Data Name",
                                      message: "What does this data represent?\n(Ex: Weight)",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Done",
                                       style: .default) {
            [weak self] action in
            
            guard let strongSelf = self else { fatalError("Can't get self in CreateHabitTrackerVC") }
            
            guard let textField = alert.textFields?.first,
                  let description = textField.text else {
                return
            }
            
            switch(type) {
            case "Number":
                let tracker = NumberTracker(context: strongSelf.context, habit: strongSelf.habit, name: description)
                strongSelf.trackers.append(tracker)
            case "Image":
                let tracker = ImageTracker(context: strongSelf.context, habit: strongSelf.habit, name: description)
                strongSelf.trackers.append(tracker)
            default:
                fatalError("Unknown type in HabitCreationVC")
            }
            
            strongSelf.tableView.reloadData()
            strongSelf.dismissKeyboard()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        alert.textFields?.first?.autocapitalizationType = .words
        
        present(alert, animated: true)
    }
}
