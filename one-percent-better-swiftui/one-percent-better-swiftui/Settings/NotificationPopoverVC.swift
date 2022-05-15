//
//  NotificationPopoverVC.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 11/6/21.
//

import UIKit

class NotificationPopoverVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var habit: Habit!
    var settingsDelegate: NotificationSettingsUpdater?
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        tableViewHeightConstraint.constant = 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if habit.notificationTime != nil {
                return 1
            } else {
                return 0
            }
        default:
            fatalError("update sections")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationDeleteCell", for: indexPath)
            return cell
        } else {
            fatalError("Fix number of elements in table")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DeleteNotificationPopover" {
            NotificationPopoverVC.deleteNotification(for: habit)
            habit.notificationTime = nil
        } else if segue.identifier == "SaveNotificationPopover" {
            saveNotification()
        }
    }
    
    func saveNotification() {
        // Remove old notification time
        NotificationPopoverVC.deleteNotification(for: habit)
        
        // Set new notification time
        habit.notificationTime = timePicker.date
        
        // Create the notification
        NotificationPopoverVC.createNotification(for: habit)
    }
    
    static func deleteNotification(for habit: Habit) {
        // remove notification
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [habit.name])
    }
    
    static func createNotification(for habit: Habit) {
        guard let notificationTime = habit.notificationTime else {
            fatalError("Habit doesn't have a notification time")
        }
        
        // add new notification
        let content = UNMutableNotificationContent()
        content.title = "\(habit.name)"
        
        if habit.streak == 0 {
            content.body = "Complete today to start a new streak!"
        } else {
            content.body = "Don't lose your \(habit.streak) day streak!"
        }
        
        
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: habit.name,
            content: content,
            trigger: trigger)
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { error in
            if error != nil {
                print(error!.localizedDescription)
            }
        }
    }
}
