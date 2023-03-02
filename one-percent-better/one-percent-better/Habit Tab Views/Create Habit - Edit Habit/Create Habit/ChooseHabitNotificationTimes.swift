//
//  ChooseHabitNotificationTimes.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 3/1/23.
//

import SwiftUI

struct ChooseHabitNotificationTimes: View {
   
   @Environment(\.managedObjectContext) var moc
   
   @EnvironmentObject var nav: HabitTabNavPath
   
   var habitName: String
   
   var frequency: HabitFrequency
   
   @Binding var hideTabBar: Bool
   
   var body: some View {
      Background {
         VStack {
            Spacer()
               .frame(height: 20)
            
            NotificationSelection()
            
            Spacer()
            
            BottomButton(label: "Done")
               .onTapGesture {
                  let _ = try? Habit(context: moc,
                                     name: habitName,
                                     frequency: frequency)
                  hideTabBar = false
                  nav.path.removeLast(3)
               }
         }
         .toolbar(.hidden, for: .tabBar)
      }
   }
}

struct ChooseHabitNotificationTimes_Previews: PreviewProvider {
    static var previews: some View {
       ChooseHabitNotificationTimes(habitName: "Horseback Riding",
                                    frequency: .timesPerDay(2),
                                    hideTabBar: .constant(true))
    }
}
