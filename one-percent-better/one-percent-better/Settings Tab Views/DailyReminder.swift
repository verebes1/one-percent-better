//
//  DailyReminder.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/19/22.
//

import SwiftUI

struct DailyReminder: View {
   
   @State private var sendNotif = false
   @State private var timeSelection = Date()
   
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
   }
}

struct DailyReminder_Previews: PreviewProvider {
    static var previews: some View {
        DailyReminder()
    }
}
