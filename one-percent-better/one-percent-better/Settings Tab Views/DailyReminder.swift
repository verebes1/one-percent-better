//
//  DailyReminder.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/19/22.
//

import SwiftUI

struct DailyReminder: View {
   
   @Environment(\.managedObjectContext) var moc
   
   var settings: Settings
   
   @State private var sendNotif = false
   @State private var timeSelection: Date
   @State private var animateBell = false
   
   
   init(settings: Settings) {
      self.settings = settings
      _sendNotif = State(initialValue: settings.dailyReminderEnabled)
      _timeSelection = State(initialValue: settings.dailyReminderTime)
   }
   
   // MARK: Function helpers
   
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
   
   // MARK: View
   
   var body: some View {
      Background {
         VStack {
            
            AnimatedHabitCreationHeader(animateBell: $animateBell,
                                        title: "Daily Reminder",
                                        subtitle: "Add a notification reminder to complete your habits")
            
            List {
               Toggle("Notification", isOn: $sendNotif)
                  .listRowBackground(Color.cardColor)
               
               DatePicker(selection: $timeSelection, displayedComponents: [.hourAndMinute]) {
                  Text("Every day at ")
               }
               .frame(height: 37)
               .listRowBackground(Color.cardColor)
            }
            .scrollContentBackground(.hidden)
            .frame(height: 180)
            
            Spacer()
         }
      }
      .onChange(of: sendNotif) { newBool in
         if newBool && !animateBell {
            animateBell = true
         }
         updateDailyReminder(to: newBool)
      }
      .onChange(of: timeSelection) { newTime in
         updateDailyReminder(time: newTime)
      }
      .onDisappear {
         Task {
            moc.perform {
               moc.assertSave()
            }
         }
      }
   }
}

struct DailyReminder_Previews: PreviewProvider {
   static let moc = CoreDataManager.previews.mainContext
   
   static func data() -> Settings {
      let settings = Settings(myContext: moc)
      settings.dailyReminderEnabled = true
      settings.dailyReminderTime = Date()
      return settings
   }

   static var previews: some View {
      VStack {
         let settings = data()
         DailyReminder(settings: settings)
            .environment(\.managedObjectContext, moc)
      }
   }
}
