//
//  TaskTableVC.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 12/2/21.
//

import UIKit
import CoreData

class TaskCell: UITableViewCell {
    static var identifier: String {
        String(describing: self)
    }
    @IBOutlet weak var taskName: UILabel!
    @IBOutlet weak var taskCheckbox: UIImageView!
    
    var task: Task! {
        didSet {
            taskName.text = task.name
            selected(task.completed)
        }
    }
    
    lazy var checkedImage = UIImage(systemName: "checkmark.circle.fill")
    lazy var uncheckedImage = UIImage(systemName: "circle")
    
    func selected(_ selected: Bool) {
        if selected {
            taskCheckbox.image = checkedImage
            taskCheckbox.tintColor = .systemGreen
        } else {
            taskCheckbox.image = uncheckedImage
            taskCheckbox.tintColor = .lightGray
        }
        
    }
}

class TaskTableVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    var allTasks: [Task] = []
    var uncompletedTasks: [Task] = []
    var completedTasks: [Task] = []
    
    var uncompletedSection: Int? {
        uncompletedTasks.isEmpty ? nil : 0
    }
    var completedSection: Int? {
        if completedTasks.isEmpty {
            return nil
        } else {
            return uncompletedSection != nil ? 1 : 0
        }
    }
    
    var context = CoreDataManager.shared.mainContext
    
    @IBAction func unwindToTaskTableVC(segue: UIStoryboardSegue) {
        CoreDataManager.shared.saveContext()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.leftBarButtonItem = editButtonItem
    }
    
    func updateTaskLists() -> ([Task], [Task], [Task]) {
        var tasks: [Task] = []
        do {
            // fetch all habits
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            tasks = try context.fetch(fetchRequest)
        } catch {
            fatalError("\(String(describing: self)) \(#function) - unable to fetch tasks!")
        }
        
        var completed: [Task] = []
        var uncompleted: [Task] = []
        
        for task in tasks {
            if task.completed {
                completed.append(task)
            } else {
                uncompleted.append(task)
            }
        }
        
        return (tasks, uncompleted, completed)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadTable()
    }
    
    func reloadTable() {
        (allTasks, uncompletedTasks, completedTasks) = updateTaskLists()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == uncompletedSection {
            // Mark as done
            uncompletedTasks[indexPath.row].completed = true
            let cell = tableView.cellForRow(at: indexPath) as! TaskCell
            cell.selected(true)
        } else if indexPath.section == completedSection {
            // Mark as not done
            completedTasks[indexPath.row].completed = false
            let cell = tableView.cellForRow(at: indexPath) as! TaskCell
            cell.selected(false)
        }
        tableView.deselectRow(at: indexPath, animated: true)
        CoreDataManager.shared.saveContext()
        reloadTable()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == uncompletedSection {
            return uncompletedTasks.count
        } else if section == completedSection {
            return completedTasks.count
        }
        fatalError("Wrong number of sections")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let hasTodo = uncompletedTasks.isEmpty ? 0 : 1
        let hasCompleted = completedTasks.isEmpty ? 0 : 1
        return hasTodo + hasCompleted
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == uncompletedSection {
            return "To-do"
        } else if section == completedSection {
            return "Completed"
        }
        fatalError("Wrong number of sections")
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TaskCell.self), for: indexPath as IndexPath) as! TaskCell

        var task: Task?
        if indexPath.section == uncompletedSection {
            task = uncompletedTasks[indexPath.row]
        } else if indexPath.section == completedSection {
            task = completedTasks[indexPath.row]
        }
        if let task = task {
            cell.task = task
            return cell
        }
        fatalError("Wrong number of sections")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    // MARK: - Editing
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)

        // Toggle table view editing.
        tableView.setEditing(editing, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, sourceView, completionHandler) in
            guard let strongSelf = self else {
                fatalError("unable to retrieve self in TaskTableVC")
            }
            var taskToRemove: Task?
            if indexPath.section == strongSelf.uncompletedSection {
                taskToRemove = strongSelf.uncompletedTasks[indexPath.row]
            } else if indexPath.section == strongSelf.completedSection {
                taskToRemove = strongSelf.completedTasks[indexPath.row]
            }
            
            guard let taskToRemove = taskToRemove else {
                return
            }
            
            // delete task
            strongSelf.context.delete(taskToRemove)
            CoreDataManager.shared.saveContext()
            strongSelf.reloadTable()
            if strongSelf.allTasks.count == 0 {
                strongSelf.setEditing(false, animated: true)
            }
            completionHandler(true)
        }
        let swipeAction = UISwipeActionsConfiguration(actions: [delete])
        swipeAction.performsFirstActionWithFullSwipe = false // Disables full swipe to delete in one motion
        return swipeAction
    }
}
