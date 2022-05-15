//
//  ViewController.swift
//  mo-ikai
//
//  Created by Jeremy on 3/10/21.
//

import UIKit

protocol NotificationSettingsUpdater {
    func reloadTable()
}


/// An object which holds all the details for a row in the table of the Settings ViewController
struct Setting {
    /// Name of the setting, for example "Export as JSON"
    var name: String
    
    /// Name of the system symbol used in the icon (SF Symbols)
    var symbolName: String
    
    /// The icon image based on the symbol name
    var iconImage: UIImage? {
        get {
            UIImage(systemName: self.symbolName)
        }
    }
    
    /// Background color of the icon
    var backgroundColor: UIColor
    
    /// A boolean indicating whether to display a disclosure indicator on the row or not
    var disclosureIndicator: Bool
    
    var segueIdentifier: String?
    
    /// The view controller that the setting segues to
//    var viewController: UIViewController?
}

class SettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var importHabits: Bool = false
    
    /// Array of settings which make up the settings Table
    var settings: [Setting] = {
        var settings: [Setting] = [
//            Setting(name: "Create Backup",
//                    symbolName: "goforward",
//                    backgroundColor: #colorLiteral(red: 0.5818830132, green: 0.2156915367, blue: 1, alpha: 1),
//                    disclosureIndicator: false,
//                    segueIdentifier: nil),
//            Setting(name: "Restore From Backup",
//                    symbolName: "gobackward",
//                    backgroundColor: #colorLiteral(red: 1, green: 0.2527923882, blue: 1, alpha: 1),
//                    disclosureIndicator: false,
//                    segueIdentifier: nil),
            Setting(name: "Export Data",
                    symbolName: "square.and.arrow.up",
                    backgroundColor: #colorLiteral(red: 1, green: 0.1857388616, blue: 0.5733950138, alpha: 1),
                    disclosureIndicator: false,
                    segueIdentifier: nil),
            Setting(name: "Import Data",
                    symbolName: "square.and.arrow.down",
                    backgroundColor: #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1),
                    disclosureIndicator: false,
                    segueIdentifier: nil),
            Setting(name: "Notifications",
                    symbolName: "bell.fill",
                    backgroundColor: #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1),
                    disclosureIndicator: true,
                    segueIdentifier: "NotificationSettingsSegue")
        ]
        return settings
    }()
    
    lazy var exportManager = ExportManager()
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsCell.self), for: indexPath) as! SettingsCell
        let setting = settings[indexPath.row]
        cell.configure(setting: setting)
        if !setting.disclosureIndicator {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SettingsCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let setting = settings[indexPath.row]
        
        if setting.name == "Export Data" {
            if let jsonFile = exportManager.createJSON(context: CoreDataManager.shared.mainContext) {
                let activityViewController = UIActivityViewController(activityItems: [jsonFile], applicationActivities: nil)
                present(activityViewController, animated: true, completion: nil)
            }
        } else if setting.name == "Import Data" {
            importHabits = true
            //Create a picker specifying file type and mode
            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.json])
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = false
            documentPicker.modalPresentationStyle = .popover
            present(documentPicker, animated: true, completion: nil)
        }
        
        if let segueId = settings[indexPath.row].segueIdentifier {
            performSegue(withIdentifier: segueId, sender: self)
        }
    }
}

// MARK: - UIDocumentPickerDelegate

extension SettingsVC: UIDocumentPickerDelegate {
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            return
        }
        var relinquish = false
        do {
            relinquish = url.startAccessingSecurityScopedResource()
            let jsonData = try Data(contentsOf: url)
            do {
                let _: ExportContainer = try exportManager.load(jsonData)
                CoreDataManager.shared.saveContext()
            } catch {
                print("IMPORT DATA ERROR: \(error)")
//                fatalError("\(#function) - Unexpected error: \(error)")
            }
        } catch {
            print("unable to load data: \(error)")
        }
        
        if relinquish {
            url.stopAccessingSecurityScopedResource()
        }
        controller.dismiss(animated: true)
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
}
