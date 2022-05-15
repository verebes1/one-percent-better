//
//  CreateTaskNameVC.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 12/2/21.
//

import UIKit
import CoreData

class CreateTaskNameCell: UITableViewCell {
    static var identifier: String {
        String(describing: self)
    }
    @IBOutlet weak var nameField: UITextField!
}

class CreateTaskNameVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    var numCells = 1
    var cellHeight: CGFloat = 50
    var task: Task!
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
        
        if self.isMovingFromParent,
            let task = task {
            context.delete(task)
            CoreDataManager.shared.saveContext()
        }
    }
    
    // MARK: - Should Perform Segue
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // Check to see if name field has been filled
        if identifier == "unwindToTaskTableVCWithSegue" {
            // Get cell
            guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CreateTaskNameCell else {
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
            
            // Create task
            if let task = task {
                task.name = name
            } else {
                guard let taskEntity = NSEntityDescription.entity(forEntityName: "Task", in: context) else {
                    fatalError("failed to create Task entity")
                }
                let task = NSManagedObject(entity: taskEntity, insertInto: context)
                task.setValue(name, forKey: "name")
                CoreDataManager.shared.saveContext()
            }
        }
        return true
    }
    
    // MARK: - Table View Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CreateTaskNameCell.identifier, for: indexPath) as! CreateTaskNameCell
        cell.nameField.delegate = self
        cell.nameField.becomeFirstResponder()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    @IBAction func donePressed(_ sender: UIButton) {
        if shouldPerformSegue(withIdentifier: "unwindToTaskTableVCWithSegue", sender: self) {
            view.endEditing(true)
            performSegue(withIdentifier: "unwindToTaskTableVCWithSegue", sender: self)
        }
    }
    
    
    // MARK: - Keyboard Methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if shouldPerformSegue(withIdentifier: "unwindToTaskTableVCWithSegue", sender: self) {
            performSegue(withIdentifier: "unwindToTaskTableVCWithSegue", sender: self)
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
