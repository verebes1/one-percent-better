//
//  AllHabitNotifications.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 3/8/23.
//

import SwiftUI

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
   
   var habits: [Habit] {
      var habits = Habit.habits(from: moc)
      habits.removeAll { habit in
         habit.notificationsArray.isEmpty
      }
      return habits
   }
   
   func totalNotifications(for habit: Habit) -> Int {
      var sum = 0
      for notif in habit.notificationsArray {
         sum += notif.scheduledNotificationsArray.count
      }
      return sum
   }
   
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
                           Text("\(totalNotifications(for: habit))")
                        }
                     }
                  }
                  //                  ForEach(notifications, id: \.self.id) { notif in
                  //                     VStack(alignment: .leading) {
                  //                        let dc = notif.dateComponents
                  //                        Text("id: ").bold() + Text("\(notif.id)")
                  //                        Text("date: ").bold() + Text("\(String(describing: dc.month!))/\(String(describing:dc.day!))/\(String(describing:dc.year!)) \(String(describing:dc.hour!)):\(String(describing:dc.minute!))")
                  //                        Text("title: ").bold() + Text("\(notif.title)")
                  //                        Text("body: ").bold() + Text("\(notif.body)")
                  //                     }
                  //                  }
                  
                  
               }
            }
         }
         .navigationDestination(for: AllHabitsNotificationsRoute.self) { route in
            if case let .chooseHabit(habit) = route {
               NotificationsForHabitDebug(habit: habit)
            }
         }
//         .onAppear {
//            Task { notifications = await fetchNotifications() }
//         }
      }
   }
}

struct AllHabitNotifications_Previews: PreviewProvider {
   static var previews: some View {
      AllHabitNotifications()
   }
}
