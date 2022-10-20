//
//  DailyReminder.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/19/22.
//

import SwiftUI

struct DailyReminder: View {
   
   @Environment(\.managedObjectContext) var moc
   
   @State private var sendNotif = false
   @State private var timeSelection: Date
   
   init() {
      _sendNotif = State(initialValue: SettingsController.shared.settings.dailyReminderEnabled)
      _timeSelection = State(initialValue: SettingsController.shared.settings.dailyReminderTime)
   }
   
   var body: some View {
      Background {
         VStack {
            HabitCreationHeader(systemImage: "bell.fill", title: "Daily Reminder", subtitle: "Add a notification reminder to complete your habits")
            
            List {
               
               Toggle("Notification", isOn: $sendNotif)
               
               DatePicker(selection: $timeSelection, displayedComponents: [.hourAndMinute]) {
                  Text("Every day at ")
               }
               .frame(height: 37)
            }
            .frame(height: 180)
            
            Spacer()
         }
      }
      .onChange(of: sendNotif) { newBool in
         SettingsController.shared.updateDailyReminder(to: newBool)
      }
      .onChange(of: timeSelection) { newTime in
         SettingsController.shared.updateDailyReminder(time: newTime)
      }
   }
}

struct DailyReminder_Previews: PreviewProvider {
    static var previews: some View {
        DailyReminder()
    }
}
