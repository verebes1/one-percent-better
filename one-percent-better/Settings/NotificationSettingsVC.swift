//
//  NotificationSettingsVC.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 1/5/22.
//

import UIKit

class NotificationSettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NotificationSettingsUpdater {
    
    @IBOutlet weak var tableView: UITableView!
    
    var habits: [Habit] = []
    
    
    @IBAction func unwindFromNotificationPopover(unwindSegue: UIStoryboardSegue) {
        tableView.reloadData()
        CoreDataManager.shared.saveContext()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        habits = Habit.updateHabitList(from: CoreDataManager.shared.mainContext)
        tableView.reloadData()
    }
    
    // Prepare for segue transition
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "NotificationSegue",
           let destination = segue.destination as? NotificationPopoverVC,
           let row = tableView.indexPathForSelectedRow?.row {
            destination.habit = habits[row]
            destination.settingsDelegate = self
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath as IndexPath)
        var content = cell.defaultContentConfiguration()
        let row = indexPath.row
        content.text = habits[row].name
        content.secondaryText = "None"
        
        if let time = habits[row].notificationTime {
            let formatter = DateComponentsFormatter()
            let timeComponent = Calendar.current.dateComponents([.hour, .minute], from: time)
            let s = formatter.string(from: timeComponent)
            content.secondaryText = s
        }
        
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habits.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func reloadTable() {
        tableView.reloadData()
    }
    
}
