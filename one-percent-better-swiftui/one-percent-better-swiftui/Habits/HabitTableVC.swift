//
//  ViewController.swift
//  mo-ikai
//
//  Created by Jeremy on 3/10/21.
//

import UIKit
import CoreData
import AVFoundation

protocol HabitCellDelegator {
    func performNewEntrySegue(habit: Habit)
    func playHaptic()
}

class HabitTableVC: UIViewController, UITableViewDataSource, UITableViewDelegate, HabitCellDelegator {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    // MARK: Storyboard Segues
    
    @IBAction func unwindToHabitTableVC(unwindSegue: UIStoryboardSegue) {
        CoreDataManager.shared.saveContext()
        tableView.reloadData()
    }
    
    @IBAction func unwindFromHabitEntryVC(unwindSegue: UIStoryboardSegue) {
        CoreDataManager.shared.saveContext()
        tableView.reloadData()
    }
    
    var habits: [Habit] = []
    var selectedHabit: Habit?
    var context = CoreDataManager.shared.mainContext
    
    // MARK: - ViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //navigationBar.largeTitleDisplayMode = .never
        
        tableView.rowHeight = HabitCell.rowHeight
        navigationBar.leftBarButtonItem = editButtonItem
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func willEnterForeground() {
        self.habits = Habit.updateHabitList(from: context)
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.habits = Habit.updateHabitList(from: context)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        setEditing(false, animated: true)
        
        if segue.identifier == "NewHabitEntrySegue",
           let destination = segue.destination as? HabitEntryVC,
           let habit = selectedHabit,
           let cell = tableView.cellForRow(at: IndexPath(row: habit.orderIndex, section: 0)) as? HabitCell {
            destination.configure(habit: habit, cell: cell, completionStatus: true)
        } else if segue.identifier == "ProgressSegue",
                  let destination = segue.destination as? ProgressVC,
                  let row = tableView.indexPathForSelectedRow?.row {
            destination.configure(habit: habits[row])
        }
    }
    
    func performNewEntrySegue(habit: Habit) {
        selectedHabit = habit
        performSegue(withIdentifier: "NewHabitEntrySegue", sender: self)
    }
    
    // MARK: - Haptic Engine
    
    func playHaptic() {
        HapticEngineManager.playHaptic()
    }

    // MARK: Table View
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        // Takes care of toggling the button's title.
        super.setEditing(editing, animated: true)
        
        // Toggle table view editing.
        tableView.setEditing(editing, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HabitCell.self), for: indexPath as IndexPath) as! HabitCell
        cell.configure(habit: habits[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completionHandler) in
            let habitToRemove = self.habits[indexPath.row]
            
            let startIndex = Int(habitToRemove.orderIndex)
            for i in (startIndex + 1) ..< self.habits.count {
                self.habits[i].orderIndex -= 1
            }
            
            // remove notification
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [habitToRemove.name])
            // delete habit
            CoreDataManager.shared.mainContext.delete(habitToRemove)
            CoreDataManager.shared.saveContext()
            self.habits = Habit.updateHabitList(from: self.context)
            if self.habits.count == 0 {
                self.setEditing(false, animated: true)
            }
            tableView.reloadData()
            completionHandler(true)
        }
        let swipeAction = UISwipeActionsConfiguration(actions: [delete])
        swipeAction.performsFirstActionWithFullSwipe = false // Disables full swipe to delete in one motion
        return swipeAction
    }
    
    // Reordering of habits
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Ensure we are moving an element and not wasting our time
        guard sourceIndexPath.row != destinationIndexPath.row else {
            return
        }
        
        // Re-order cell indices
        if sourceIndexPath.row > destinationIndexPath.row {
            habits[sourceIndexPath.row].orderIndex = destinationIndexPath.row
            for i in destinationIndexPath.row ..< sourceIndexPath.row {
                habits[i].orderIndex += 1
            }
        } else {
            habits[sourceIndexPath.row].orderIndex = destinationIndexPath.row
            for i in (sourceIndexPath.row + 1) ... destinationIndexPath.row  {
                habits[i].orderIndex -= 1
            }
        }
        
        // Save context
        CoreDataManager.shared.saveContext()
        // Sort by index
        habits = Habit.updateHabitList(from: context)
    }
    
    // Selecting a row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        if tableView.isEditing {
        //            if let viewController = storyboard?.instantiateViewController(identifier: "HabitEditVC") as? HabitEditVC {
        //                let backButton = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        //                navigationBar.backBarButtonItem = backButton
        //                viewController.habit = habits[indexPath.row]
        //                navigationController?.pushViewController(viewController, animated: true)
        //            }
        //        }
        
        
    }
    
    
    // this disables swipe to delete, but still allows the delete button to work in edit
    // TODO: - this does not disable swipe to delete
    //    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
    //        if tableView.isEditing{
    //            return .delete
    //        }
    //        return .none
    //    }
    
}

