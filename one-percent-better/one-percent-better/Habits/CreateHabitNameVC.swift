//
//  CreateHabitNameVC.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 11/27/21.
//

import Foundation
import UIKit


class CreateHabitNameCell: UITableViewCell {
    
    static var identifier: String {
        String(describing: self)
    }
    @IBOutlet weak var nameField: UITextField!
}

protocol UpdateHabitWhileCreating {
    func update(habit: Habit)
}

class CreateHabitNameVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var doneButtonBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Variables
    
    var numCells = 1
    var cellHeight: CGFloat = 50
    var habit: Habit!
    // Do not animate moving the done button if we are first loading the view
    // because the keyboard doesn't animate up, it just appears already up
    var firstShowKeyboard: Bool = true
    var context = CoreDataManager.shared.mainContext
    
    // MARK: - View Controller Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstShowKeyboard = true
        // Subscribe to keyboard appearing to move "Done" button
        subscribeToShowKeyboardNotifications()
        
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        tableViewHeightConstraint.constant = CGFloat(numCells) * cellHeight
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
        
        if self.isMovingFromParent,
            let habit = habit {
            CoreDataManager.shared.mainContext.delete(habit)
            CoreDataManager.shared.saveContext()
        }
    }
    
    // MARK: - Segue Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createNameSegue",
           let destination = segue.destination as? CreateHabitTimeVC {
            destination.habit = habit
            destination.delegate = self
            
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // Check to see if name field has been filled
        if identifier == "createNameSegue" {
            // Get cell
            guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CreateHabitNameCell else {
                fatalError("Can't get cell in \(String(describing: self)))")
            }
            
            // Check if name field is empty
            guard let name = cell.nameField.text, !name.isEmpty else {
                let errorAlert = UIAlertController(title: "Please Enter a Name",
                                                   message: nil,
                                                   preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(
                                        title: "OK",
                                        style: .default,
                                        handler: nil))
                present(errorAlert, animated: true, completion: nil)
                return false
            }
            
            // If habit is already created, then update name
            if let habit = habit {
                do {
                    try habit.setName(name)
                } catch HabitCreationError.duplicateName {
                    showDuplicateNameAlert(name)
                    return false
                } catch {
                    fatalError("Unexpected error in \(#function): \(error)")
                }
            } else {
                if let habit = try? Habit(context: context, name: name) {
                    self.habit = habit
                    return true
                } else {
                    showDuplicateNameAlert(name)
                    return false
                }
            }
        }
        return true
    }
    
    func showDuplicateNameAlert(_ name: String) {
        let errorAlert = UIAlertController(title: "Duplicate Name",
                                           message: "\"\(name)\" is already taken, choose another habit name.",
                                           preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(
                                title: "OK",
                                style: .default,
                                handler: nil))
        present(errorAlert, animated: true, completion: nil)
    }
    
    // MARK: - Table View Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CreateHabitNameCell.identifier, for: indexPath) as! CreateHabitNameCell
        cell.nameField.delegate = self
        cell.nameField.becomeFirstResponder()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    // MARK: - Keyboard Methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if shouldPerformSegue(withIdentifier: "createNameSegue", sender: self) {
            performSegue(withIdentifier: "createNameSegue", sender: self)
        }
        return true
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardHeight = keyboardSize.cgRectValue.height
        doneButtonBottomConstraint.constant = keyboardHeight - view.safeAreaInsets.bottom + 15
        
        // Animate
        if firstShowKeyboard {
            firstShowKeyboard = false
        } else {
            let animationDuration = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
            UIView.animate(withDuration: animationDuration) {
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        doneButtonBottomConstraint.constant = 10
        
        // Animate
        let userInfo = notification.userInfo
            let animationDuration = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
            UIView.animate(withDuration: animationDuration) {
                self.view.layoutIfNeeded()
            }
    }

    func subscribeToShowKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

// MARK: - Update habit

extension CreateHabitNameVC: UpdateHabitWhileCreating {
    func update(habit: Habit) {
        self.habit = habit
    }
}
