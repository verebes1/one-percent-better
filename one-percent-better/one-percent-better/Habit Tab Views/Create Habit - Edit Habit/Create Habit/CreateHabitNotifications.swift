//
//  CreateHabitNotifications.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 3/1/23.
//

import SwiftUI
import Combine

struct CreateHabitNotifications: View {
   
   @Environment(\.managedObjectContext) var moc
   
   @EnvironmentObject var nav: HabitTabNavPath
   
   var habit: Habit
   
   @Binding var hideTabBar: Bool
   
   @State private var hasChanged: Set<Notification> = []
   
   var habitFrequency: HabitFrequency
   
   init(habit: Habit, habitFrequency: HabitFrequency, hideTabBar: Binding<Bool>) {
      self.habit = habit
      self._hideTabBar = hideTabBar
      self.habitFrequency = habitFrequency
   }
   
   var body: some View {
      Background {
         VStack {
            Spacer()
               .frame(height: 20)
            
            NotificationSelection(habit: habit, hasChanged: $hasChanged)
            
            Spacer()
            
            BottomButton(label: "Done")
               .onTapGesture {
                  
                  Task { habit.addNotifications(habit.notificationsArray) }
                  
                  hideTabBar = false
                  nav.path.removeLast(3)
               }
         }
      }
      .onAppear {
         let _ = habit.changeFrequency(to: habitFrequency)
      }
      .toolbar(.hidden, for: .tabBar)
   }
}

struct ChooseHabitNotificationTimes_Previews: PreviewProvider {
   
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
      CreateHabitNotifications(habit: data(), habitFrequency: .timesPerDay(1), hideTabBar: .constant(true))
   }
}