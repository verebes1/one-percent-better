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
         moc.fatalSave()
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
      
      let notifications = generateNotifications(n: 64)
      
      var date = DateComponents()
      date.hour = Cal.component(.hour, from: settings.dailyReminderTime)
      date.minute = Cal.component(.minute, from: settings.dailyReminderTime)
      
      setupNotifications(from: Date(), index: 0, time: date, notifications: notifications)
   }
   
   func generateNotifications(n: Int) -> [UNMutableNotificationContent] {      
      var notifs: [UNMutableNotificationContent] = []
      for _ in 0 ..< n {
         let content = UNMutableNotificationContent()
         content.title = "Daily Reminder"
         content.subtitle = DailyReminderNotifications.messages.randomElement()!
         content.sound = UNNotificationSound.default
         notifs.append(content)
      }
      return notifs
   }
   
   /// Set up the next N notifications, where N = messages.count
   /// - Parameters:
   ///   - date: The start date (including this day)
   ///   - time: What time to send the notification
   ///   - messages: The next N notification messages to use
   ///
   func setupNotifications(from date: Date, index: Int, time: DateComponents, notifications: [UNMutableNotificationContent]) {
      
      for i in 0 ..< notifications.count {
         if (i + index) >= 64 {
            break
         }
         let dayComponents = Cal.dateComponents([.day, .month, .year,], from: Cal.add(days: i, to: date))
         var dayAndTime = time
         dayAndTime.day = dayComponents.day
         dayAndTime.month = dayComponents.month
         dayAndTime.year = dayComponents.year
         let trigger = UNCalendarNotificationTrigger(dateMatching: dayAndTime, repeats: false)
         
         let offset = index + i
         let request = UNNotificationRequest(identifier: "OnePercentBetter-DailyReminder-\(offset)", content: notifications[i], trigger: trigger)
         UNUserNotificationCenter.current().add(request)
      }
   }
   
   func removeNotification() {
      UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["OnePercentBetter-DailyReminder"])
   }
   
   func removeAllNotifications() {
      for i in 0 ..< 64 {
         UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["OnePercentBetter-DailyReminder-\(i)"])
      }
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
                     
                     NavigationLink(value: SettingsNavRoute.habitNotifications) {
                        IconTextRow(title: "Habit Notifications", icon: "bell.fill", color: .cyan)
                     }
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
