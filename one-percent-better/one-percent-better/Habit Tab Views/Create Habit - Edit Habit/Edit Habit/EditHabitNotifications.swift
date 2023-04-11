//
//  EditHabitNotifications.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 3/5/23.
//

import SwiftUI

struct EditHabitNotifications: View {
   @Environment(\.managedObjectContext) var moc
   
   var habit: Habit
   
   @State private var hasChanged: Set<Notification> = []
   
   var body: some View {
      Background {
         VStack {
            Spacer()
               .frame(height: 20)
            
            NotificationSelection(habit: habit, hasChanged: $hasChanged)
            
            Spacer()
         }
      }
      .onDisappear {
         for notif in hasChanged {
            if !notif.isDeleted {
               notif.reset()
               habit.addNotification(notif)
            }
         }
      }
      .toolbar(.hidden, for: .tabBar)
   }
}

struct EditHabitNotifications_Previews: PreviewProvider {
   
   static func data() -> Habit {
      let context = CoreDataManager.previews.mainContext
      
      let day0 = Date()
      let day1 = Cal.date(byAdding: .day, value: -1, to: day0)!
      let day2 = Cal.date(byAdding: .day, value: -2, to: day0)!
      
      let h1 = try? Habit(context: context, name: "Swimming")
      
      let habits = Habit.habits(from: context)
      return habits.first!
   }
   
   static var previews: some View {
      let habit = data()
      EditHabitNotifications(habit: habit)
   }
}
