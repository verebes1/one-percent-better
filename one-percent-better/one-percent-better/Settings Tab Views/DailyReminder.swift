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
   @State private var animateBell = false
   
   init(settings: Settings) {
      _sendNotif = State(initialValue: settings.dailyReminderEnabled)
      _timeSelection = State(initialValue: settings.dailyReminderTime)
   }
   
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
         
         vm.updateDailyReminder(to: newBool)
         moc.fatalSave()
      }
      .onChange(of: timeSelection) { newTime in
         vm.updateDailyReminder(time: newTime)
         moc.fatalSave()
      }
   }
}

//struct DailyReminder_Previews: PreviewProvider {
//   static func data() -> Settings {
//      let moc = CoreDataManager.previews.mainContext
//      let _ = Settings(context: moc)
//
//      let settings = Settings.settings(from: moc)
//
//      return settings.first!
//   }
//
//   static var previews: some View {
//      let moc = CoreDataManager.previews.mainContext
//      let settings = data()
//      let vm = SettingsViewModel(moc)
//      return (
//         DailyReminder(settings: settings)
//            .environmentObject(vm)
//      )
//   }
//}
