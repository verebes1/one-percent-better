//
//  NotificationSelection.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/14/22.
//

import SwiftUI

struct NotificationSelection: View {
   
   @State private var sendNotif = false
   @State private var timeSelection = Date()
   
    var body: some View {
       VStack {
          
          HabitCreationHeader(systemImage: "bell.fill", title: "Reminder", subtitle: "Add a notification reminder to complete your habit")
          
          List {
             
             Toggle("Notification", isOn: $sendNotif)
             
             DatePicker(selection: $timeSelection, displayedComponents: [.hourAndMinute]) {
                Text("Time ")
             }
             .frame(height: 37)
          }
          .frame(height: 180)

       }
    }
}

struct NotificationSelection_Previews: PreviewProvider {
    static var previews: some View {
       Background {
          NotificationSelection()
       }
    }
}
