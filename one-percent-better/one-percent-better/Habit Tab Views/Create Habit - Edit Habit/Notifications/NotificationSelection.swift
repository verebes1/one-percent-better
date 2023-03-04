//
//  NotificationSelection.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/14/22.
//

import SwiftUI


class Notification: Identifiable, Equatable, ObservableObject {
   var id = UUID()
   
   static func == (lhs: Notification, rhs: Notification) -> Bool {
      lhs.id == rhs.id
   }
}

class SpecificTimeNotification: Notification {
   @Published var time = Date()
}

class RandomTimeNotification: Notification {
   @Published var fromTime = {
      var components = DateComponents()
      components.hour = 9
      components.minute = 0
      return Cal.date(from: components) ?? Date()
   }()
   @Published var toTime = {
      var components = DateComponents()
      components.hour = 17
      components.minute = 0
      return Cal.date(from: components) ?? Date()
   }()
}

class NotificationSelectionModel: ObservableObject {
   @Published var notifications: [Notification] = [
      SpecificTimeNotification(),
      RandomTimeNotification()
   ]
   
   func deleteNotification(from source: IndexSet) {
      notifications.remove(atOffsets: source)
   }
}

struct NotificationSelection: View {
   
   @Environment(\.colorScheme) var scheme
   
   @ObservedObject var vm = NotificationSelectionModel()
   
   @State private var sendNotif = false
   @State private var animateBell = false
   
   @State private var selectFrequency = false
   
   private var textColor: Color {
      scheme == .light ? .white : .black
   }
   
   var body: some View {
      Background {
         VStack(spacing: 10) {
            
            AnimatedHabitCreationHeader(animateBell: $animateBell,
                                        title: "Reminder",
                                        subtitle: "Add a reminder to complete your habit.")
            
            Menu {
               Button {
                  animateBell.toggle()
                  vm.notifications.append(SpecificTimeNotification())
               } label: {
                  Label("Specific Time", systemImage: "clock")
               }
               
               Button {
                  animateBell.toggle()
                  vm.notifications.append(RandomTimeNotification())
               } label: {
                  Label("Random Time", systemImage: "dice")
               }
            } label: {
               VStack {
                  Button {
                     selectFrequency = true
                  } label: {
                     HStack {
                        Image(systemName: "plus")
                        Text("Add Reminder")
                     }
                     .padding(.vertical, 12)
                     .padding(.horizontal, 20)
                     .fontWeight(.medium)
                     .foregroundColor(Style.accentColor)
//                     .background(Style.accentColor)
//                     .foregroundColor(textColor)
                  }
               }
               .background(Color.cardColor)
               .cornerRadius(radius: 10)
               .padding(.horizontal, 20)
            }
            
            if !vm.notifications.isEmpty {
               VStack {
                  List {
                     Section {
                        ForEach(0 ..< vm.notifications.count, id: \.self) { i in
                           let notification = vm.notifications[i]
                           NotificationRow(notification: notification, index: i)
                              .listRowBackground(Color.cardColor)
                              .listRowSeparatorTint(.gray, edges: .bottom)
                              .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
                                  return -20
                              }
                        }
                        .onDelete(perform: vm.deleteNotification)
                     } footer: {
                        HStack {
                           Spacer()
                           Text("Swipe left to delete a notification")
                              .font(.system(size: 12))
                              .foregroundColor(.secondaryLabel)
                           Spacer()
                        }
                     }
                  }
                  .scrollContentBackground(.hidden)
                  .animation(.easeInOut, value: vm.notifications)
               }
            }
            Spacer()
         }
      }
      .onChange(of: sendNotif) { newBool in
         if newBool && !animateBell {
            animateBell = true
         }
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

struct SpecificTimeNotificationRow: View {
   
   @ObservedObject var notification: SpecificTimeNotification
   
   var body: some View {
      HStack {
         Spacer()
         Text("Every day at ")
         JustDatePicker(time: $notification.time)
         Spacer()
      }
      .padding(.vertical, 1)
   }
}

struct RandomTimeNotificationRow: View {
   
   @ObservedObject var notification: RandomTimeNotification
   
   var body: some View {
      VStack {
         Text("Random time between")
         HStack {
            Spacer()
            JustDatePicker(time: $notification.fromTime)
            Text(" and ")
            JustDatePicker(time: $notification.toTime)
            Spacer()
         }
      }
   }
}

struct NotificationRow: View {
   
   @ObservedObject var notification: Notification
   
   var index: Int
   
   var specificTimeBinding: Binding<SpecificTimeNotification>?
   
   var body: some View {
      ZStack {
         if let specificTime = notification as? SpecificTimeNotification {
            SpecificTimeNotificationRow(notification: specificTime)
         } else if let randomTime = notification as? RandomTimeNotification {
            RandomTimeNotificationRow(notification: randomTime)
         }
         
         HStack {
            ZStack {

               Circle()
                  .foregroundColor(Color.cardColorLighter)

               Text("\(index + 1)")
                  .font(.system(size: 13))
                  .foregroundColor(.label)
                  .padding(6)
            }
            .fixedSize()
            Spacer()
         }
      }
   }
}

struct JustDatePicker: View {
   
   @Binding var time: Date
   
   var body: some View {
      DatePicker("", selection: $time, displayedComponents: [.hourAndMinute])
         .frame(width: 90)
         .offset(x: -4)
   }
}
