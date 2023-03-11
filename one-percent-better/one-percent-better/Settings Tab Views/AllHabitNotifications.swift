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

struct AllHabitNotifications: View {
   
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
   
   var body: some View {
      Background {
         VStack {
            if notifications.isEmpty {
               Text("No notifications")
            } else {
               List {
                  ForEach(notifications, id: \.self.id) { notif in
                     VStack(alignment: .leading) {
                        let dc = notif.dateComponents
                        Text("id: ").bold() + Text("\(notif.id)")
                        Text("date: ").bold() + Text("\(String(describing: dc.month!))/\(String(describing:dc.day!))/\(String(describing:dc.year!)) \(String(describing:dc.hour!)):\(String(describing:dc.minute!))")
                        Text("title: ").bold() + Text("\(notif.title)")
                        Text("body: ").bold() + Text("\(notif.body)")
                     }
                  }
               }
            }
         }
         .onAppear {
            Task { notifications = await fetchNotifications() }
         }
      }
   }
}

struct AllHabitNotifications_Previews: PreviewProvider {
   static var previews: some View {
      AllHabitNotifications()
   }
}
