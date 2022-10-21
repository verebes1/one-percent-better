//
//  SettingsView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/12/22.
//

import SwiftUI
import CoreData

enum SettingsNavRoute: Hashable {
   case dailyReminder
   case importData
}

class SettingsViewModel: NSObject, NSFetchedResultsControllerDelegate, ObservableObject {
   
   private let settingsController: NSFetchedResultsController<Settings>
   private let moc: NSManagedObjectContext
   
   init(_ context: NSManagedObjectContext) {
      settingsController = Settings.resultsController(context: context, sortDescriptors: [])
      moc = context
      super.init()
      settingsController.delegate = self
      try? settingsController.performFetch()
      
      guard let settingsArr = settingsController.fetchedObjects else {
         fatalError("Unable to retrieve settings")
      }
      
      if settingsArr.isEmpty {
         let _ = Settings(myContext: moc)
         moc.fatalSave()
      } else if settingsArr.count > 1 {
         fatalError("Too many settings entities")
      }
   }
   
   func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
      objectWillChange.send()
   }
   
   var settings: Settings {
      guard let settingsArr = settingsController.fetchedObjects else {
         fatalError("Unable to retrieve settings")
      }
      guard settingsArr.count == 1 else {
         fatalError("Not exactly 1 setting! Count: \(settingsArr.count)")
      }
      return settingsArr[0]
   }
   
   func requestNotifPermission() {
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
         if success {
            print("All set!")
         } else if let error = error {
            print(error.localizedDescription)
         }
      }
   }
   
   func addNotification() {
      let content = UNMutableNotificationContent()
      content.title = "Daily Reminder"
      content.subtitle = "Mark your habits as completed!"
      content.sound = UNNotificationSound.default
      
      var date = DateComponents()
      date.hour = Calendar.current.component(.hour, from: settings.dailyReminderTime)
      date.minute = Calendar.current.component(.minute, from: settings.dailyReminderTime)
      let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
      
      let request = UNNotificationRequest(identifier: "OnePercentBetter-DailyReminder", content: content, trigger: trigger)
      
      // add our notification request
      UNUserNotificationCenter.current().add(request)
   }
   
   func removeNotification() {
      UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["OnePercentBetter-DailyReminder"])
   }
   
   func updateDailyReminder(to enabled: Bool) {
      settings.dailyReminderEnabled = enabled
      
      if enabled {
         requestNotifPermission()
         addNotification()
      } else {
         removeNotification()
      }
   }
   
   func updateDailyReminder(time: Date) {
      settings.dailyReminderTime = time
      
      if settings.dailyReminderEnabled {
         removeNotification()
         addNotification()
      }
   }
}

struct SettingsView: View {
   
   @Environment(\.managedObjectContext) var moc
   
   var exportManager = ExportManager()
   
   @ObservedObject var vm: SettingsViewModel
   
   @State private var exportJson: URL = URL(fileURLWithPath: "")
   @State private var showActivityController = false
   @State private var fileContent = ""
   @State private var showDocumentPicker = false
   
   var body: some View {
      NavigationStack {
         Background {
            VStack {
               List {
                  Section(header: Text("Notifications")) {
                     NavigationLink(value: SettingsNavRoute.dailyReminder) {
                        DailyReminderRow()
                           .environmentObject(vm)
                     }
                  }
                  
                  Section(header: Text("Data")) {
                     Button {
                        if let jsonFile = exportManager.createJSON(context: CoreDataManager.shared.mainContext) {
                           exportJson = jsonFile
                           showActivityController = true
                        }
                     } label: {
                        IconTextRow(title: "Export Data", icon: "square.and.arrow.up", color: .red)
                     }
                     .buttonStyle(PlainButtonStyle())
                     
                     Button {
                        showDocumentPicker = true
                     } label: {
                        IconTextRow(title: "Import Data", icon: "square.and.arrow.down", color: .blue)
                     }
                     .buttonStyle(PlainButtonStyle())
                  }
               }
               .listStyle(.insetGrouped)
               .navigationDestination(for: SettingsNavRoute.self) { route in
                  switch route {
                  case .dailyReminder:
                     DailyReminder(settings: vm.settings)
                        .environmentObject(vm)
                  case .importData:
                     DocumentPicker()
                  }
               }
               .sheet(isPresented: $showDocumentPicker) {
                  DocumentPicker()
               }
               .sheet(isPresented: $showActivityController) {
                  ActivityViewController(jsonFile: $exportJson)
               }
            }
         }
         .navigationTitle("Settings")
      }
   }
}

struct SettingsView_Previews: PreviewProvider {
   
   static func data() {
      let context = CoreDataManager.previews.mainContext
      let _ = Settings(context: context)
   }
   
   static var previews: some View {
      let moc = CoreDataManager.previews.mainContext
      let _ = data()
      SettingsView(vm: SettingsViewModel(moc))
   }
}
