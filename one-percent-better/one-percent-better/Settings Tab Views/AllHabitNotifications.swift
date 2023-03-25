//
//  AllHabitNotifications.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 3/8/23.
//

import SwiftUI
import CoreData

struct NotificationDetail {
   var id: String
   var dateComponents: DateComponents
   var title: String
   var body: String
}

enum AllHabitsNotificationsRoute: Hashable {
   case chooseHabit(Habit)
}

struct AllHabitNotifications: View {
   
   @Environment(\.managedObjectContext) var moc
   
   func fetchNotifications() async -> [NotificationDetail] {
      print("Fetching notification details")
      return await withCheckedContinuation { continuation in
         UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("~~Received notification details!!")
            var notifs: [NotificationDetail] = []
            for request in requests {
               guard let calTrigger = request.trigger as? UNCalendarNotificationTrigger else {
                  continue
               }
               let notif = NotificationDetail(id: request.identifier,
                                              dateComponents: calTrigger.dateComponents,
                                              title: request.content.title,
                                              body: request.content.body)
               notifs.append(notif)
            }
            continuation.resume(returning: notifs)
         }
      }
   }
   
   @State private var notifications: [NotificationDetail] = []
   
   @FetchRequest(entity: Habit.entity(),
                 sortDescriptors: [NSSortDescriptor(keyPath: \Habit.orderIndex, ascending: true)]) var habits: FetchedResults<Habit>
   
   var body: some View {
      Background {
         VStack {
            if habits.isEmpty {
               Text("No notifications")
            } else {
               List {
                  
                  ForEach(habits, id: \.self.id) { habit in
                     NavigationLink(value: AllHabitsNotificationsRoute.chooseHabit(habit)) {
                        HStack {
                           Text(habit.name)
                           Spacer()
                           let totalNum = habit.notificationsArray.reduce(0) { partialResult, nextResult in
                              partialResult + nextResult.scheduledNotificationsArray.count
                           }
                           Text("\(totalNum)")
                        }
                     }
                  }
               }
            }
         }
         .navigationDestination(for: AllHabitsNotificationsRoute.self) { route in
            if case let .chooseHabit(habit) = route {
               NotificationsForHabitDebug(habit: habit)
            }
         }
      }
   }
}

struct AllHabitNotifications_Previews: PreviewProvider {
   static var previews: some View {
      AllHabitNotifications()
   }
}
