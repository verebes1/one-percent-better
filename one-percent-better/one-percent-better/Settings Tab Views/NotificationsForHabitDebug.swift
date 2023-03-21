//
//  NotificationsForHabitDebug.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 3/15/23.
//

import SwiftUI

struct NotificationsForHabitDebug: View {
   
   var habit: Habit
   
   var body: some View {
      Background {
         VStack {
            ForEach(habit.notificationsArray, id: \.self.id) { notification in
               Text("id: \(notification.id)")
               List {
                  ForEach(notification.scheduledNotificationsArray, id: \.self.index) { notif in
                     VStack(alignment: .leading) {
                        Text("index: ").bold() + Text("\(notif.index)")
                        Text("string: ").bold() + Text("\(notif.string)")
                        Text("date: ").bold() + Text("\(notif.date)")
                        Text("id: ").bold() + Text("\(notif.notification.id)")
                     }
                  }
               }
            }
         }
      }
   }
}

//struct NotificationsForHabitDebug_Previews: PreviewProvider {
//   static var previews: some View {
//      NotificationsForHabitDebug()
//   }
//}
