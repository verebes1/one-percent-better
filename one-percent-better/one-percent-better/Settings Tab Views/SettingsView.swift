//
//  SettingsView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/12/22.
//

import SwiftUI
import CoreData
import OpenAI

enum SettingsNavRoute: Hashable {
   case appearance
   case dailyReminder(Settings?)
   case habitNotifications
   case importData
}

class SettingsViewModel: NSObject, NSFetchedResultsControllerDelegate, ObservableObject {
   
   private let settingsController: NSFetchedResultsController<Settings>
   private let moc: NSManagedObjectContext
   let client = Client(apiKey: "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")
   
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
         moc.assertSave()
      } else if settingsArr.count > 1 {
         assert(false, "Too many settings entities")
      }
   }
   
   func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
      objectWillChange.send()
   }
   
   var settings: Settings? {
      guard let settingsArr = settingsController.fetchedObjects else {
         //         fatalError("Unable to retrieve settings")
         return nil
      }
      guard settingsArr.count == 1 else {
         //         fatalError("Not exactly 1 setting! Count: \(settingsArr.count)")
         return nil
      }
      return settingsArr[0]
   }
   
   func requestNotifPermission() {
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
         if success {
            print("Notification permission granted!")
         } else if let error = error {
            print(error.localizedDescription)
         }
      }
   }
   
   func addNotification() {
      guard let settings = settings else {
         return
      }
      
      var date = DateComponents()
      date.hour = Cal.component(.hour, from: settings.dailyReminderTime)
      date.minute = Cal.component(.minute, from: settings.dailyReminderTime)

      let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
      let content = UNMutableNotificationContent()
      content.title = "Daily Reminder"
      content.subtitle = "Make it a habit. Believe in yourself."
      content.sound = UNNotificationSound.default
      let request = UNNotificationRequest(identifier: "OnePercentBetter-DailyReminder", content: content, trigger: trigger)
      UNUserNotificationCenter.current().add(request)
   }
   
   func removeNotification() {
      UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["OnePercentBetter-DailyReminder"])
   }
   
   func updateDailyReminder(to enabled: Bool) {
      guard let settings = settings else {
         return
      }
      settings.dailyReminderEnabled = enabled
      
      if enabled {
         requestNotifPermission()
         addNotification()
      } else {
         removeNotification()
      }
   }
   
   func updateDailyReminder(time: Date) {
      guard let settings = settings else {
         return
      }
      settings.dailyReminderTime = time
      
      if settings.dailyReminderEnabled {
         removeNotification()
         addNotification()
      }
   }
   
   //   func updateAppearance(to mode: Appearance) {
   //
   //   }
}

struct SettingsView: View {
   
   @Environment(\.managedObjectContext) var moc
   
   var exportManager = ExportManager()
   
   @ObservedObject var vm: SettingsViewModel
   
   @State private var exportJson: URL = URL(fileURLWithPath: "")
   @State private var showActivityController = false
   @State private var fileContent = ""
   @State private var showDocumentPicker = false
   
   var versionFooter: some View {
      VStack {
         HStack {
            Spacer()
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unkown"
            Text("Version \(appVersion)")
            Spacer()
         }
         Text("Made by ") + Text("Jeremy").foregroundColor(.primary) + Text(" from 🇺🇸")
      }
   }
   
   var body: some View {
      NavigationStack {
         Background {
            VStack {
               List {
                  //                  Section(header: Text("Appearance (Coming Soon)")) {
                  //                     NavigationLink(value: SettingsNavRoute.appearance) {
                  //                        ChangeAppearanceRow()
                  //                           .environmentObject(vm)
                  //                     }
                  //                  }
                  //                  .listRowBackground(Color.cardColor)
                  
                  Section(header: Text("Notifications")) {
                     NavigationLink(value: SettingsNavRoute.dailyReminder(vm.settings)) {
                        DailyReminderRow()
                           .environmentObject(vm)
                     }
                     
//                     NavigationLink(value: SettingsNavRoute.habitNotifications) {
//                        IconTextRow(title: "Habit Notifications", icon: "bell.fill", color: .cyan)
//                     }
                  }
                  .listRowBackground(Color.cardColor)
                  
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
                  .listRowBackground(Color.cardColor)
                  
                  Section(footer: versionFooter) {
                     //                     Text("v1.0.6")
                  }
                  .listRowBackground(Color.cardColor)
               }
               .listStyle(.insetGrouped)
               .scrollContentBackground(.hidden)
               .navigationDestination(for: SettingsNavRoute.self) { [vm] route in
                  switch route {
                  case .appearance:
                     // TODO: Make this a menu, or a whole view?
                     // Maybe a whole view with an animated sun/moon which show and hide
                     EmptyView()
                  case .dailyReminder(let settings):
                     if let set = settings {
                        DailyReminder(settings: set)
                           .environmentObject(vm)
                     }
                  case .habitNotifications:
                     AllHabitNotifications()
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
      NavigationStack {
         SettingsView(vm: SettingsViewModel(moc))
      }
   }
}
