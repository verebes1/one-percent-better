//
//  DailyReminder.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/19/22.
//

import SwiftUI

struct DailyReminder: View {
   
   @Environment(\.managedObjectContext) var moc
   
   @EnvironmentObject var vm: SettingsViewModel
   
   @State private var sendNotif = false
   @State private var timeSelection: Date
   
   init(settings: Settings) {
      _sendNotif = State(initialValue: settings.dailyReminderEnabled)
      _timeSelection = State(initialValue: settings.dailyReminderTime)
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
         vm.updateDailyReminder(to: newBool)
         moc.fatalSave()
      }
      .onChange(of: timeSelection) { newTime in
         vm.updateDailyReminder(time: newTime)
         moc.fatalSave()
      }
   }
}

struct DailyReminder_Previews: PreviewProvider {
   
   static func data() {
      let context = CoreDataManager.previews.mainContext
      let _ = Settings(context: context)
   }
   
   static var previews: some View {
      let moc = CoreDataManager.previews.mainContext
      let _ = data()
      let vm = SettingsViewModel(moc)
      DailyReminder(settings: vm.settings)
         .environmentObject(vm)
   }
}
