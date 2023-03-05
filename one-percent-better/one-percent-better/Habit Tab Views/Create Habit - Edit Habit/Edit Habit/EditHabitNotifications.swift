//
//  EditHabitNotifications.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 3/5/23.
//

import SwiftUI

struct EditHabitNotifications: View {
   @Environment(\.managedObjectContext) var moc
   
   @EnvironmentObject var nav: HabitTabNavPath
   @EnvironmentObject var habit: Habit
   
   var originalNotifications: [Notification]
   
   @State private var notifications: [Notification] = []
   
   init(notifications: [Notification]) {
      self.originalNotifications = notifications
      self._notifications = State(initialValue: notifications)
   }
   
   var body: some View {
      Background {
         VStack {
            Spacer()
               .frame(height: 20)
            
            NotificationSelection(notifications: $notifications)
            
            Spacer()
         }
         .onDisappear {
            // TODO: 1.0.9
//            if notifications != habit.notifications() {
//               habit.changeNotifications(to: notifications)
//            }
            if notifications != originalNotifications {
               habit.removeAllNotifications()
               // TODO: 1.0.9 better logic to add and remove
               habit.addNotifications(notifications: notifications)
            }
         }
         .toolbar(.hidden, for: .tabBar)
      }
   }
}

struct EditHabitNotifications_Previews: PreviewProvider {
    static var previews: some View {
        EditHabitNotifications(notifications: [])
    }
}
