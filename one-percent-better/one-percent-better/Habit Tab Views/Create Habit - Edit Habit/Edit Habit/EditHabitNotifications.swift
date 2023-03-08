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
   
   var habit: Habit
   
   var originalNotifications: [Notification] = []
   
   init(habit: Habit) {
      self.habit = habit
//      self.originalNotifications = habit.notificationsArray.map { $0.copy() as! Notification }
   }
   
   var body: some View {
      Background {
         VStack {
            Spacer()
               .frame(height: 20)
            
            NotificationSelection(habit: habit)
            
            Spacer()
         }
         .onDisappear {
//            if originalNotifications != habit.notificationsArray {
               print("notifications array is different!! Need to update")
               habit.addNotifications(habit.notificationsArray)
//            }
         }
         .toolbar(.hidden, for: .tabBar)
      }
   }
}

struct EditHabitNotifications_Previews: PreviewProvider {
   
   static func data() -> Habit {
      let context = CoreDataManager.previews.mainContext
      
      let day0 = Date()
      let day1 = Cal.date(byAdding: .day, value: -1, to: day0)!
      let day2 = Cal.date(byAdding: .day, value: -2, to: day0)!
      
      let h1 = try? Habit(context: context, name: "Swimming")
      h1?.markCompleted(on: day0)
      h1?.markCompleted(on: day1)
      h1?.markCompleted(on: day2)
      
      if let h1 = h1 {
         let t1 = NumberTracker(context: context, habit: h1, name: "Laps")
         t1.add(date: day0, value: "3")
         t1.add(date: day1, value: "2")
         t1.add(date: day2, value: "1")
         
         let t2 = ImageTracker(context: context, habit: h1, name: "Progress Pics")
         let patioBefore = UIImage(named: "patio-before")!
         t2.add(date: day0, value: patioBefore)
         
         let _ = ExerciseTracker(context: context, habit: h1, name: "Bench Press")
      }
      
      let habits = Habit.habits(from: context)
      return habits.first!
   }
   
   static var previews: some View {
      let habit = data()
      EditHabitNotifications(habit: habit)
   }
}
