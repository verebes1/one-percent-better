//
//  NotificationSelection.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/14/22.
//

import SwiftUI


//class Notification: Identifiable, Equatable, ObservableObject {
//   var id = UUID()
//
//   static func == (lhs: Notification, rhs: Notification) -> Bool {
//      lhs.id == rhs.id
//   }
//}
//
//class SpecificTimeNotification: Notification {
//   @Published var time = Date()
//}
//
//class RandomTimeNotification: Notification {
//   @Published var fromTime = {
//      var components = DateComponents()
//      components.hour = 9
//      components.minute = 0
//      return Cal.date(from: components) ?? Date()
//   }()
//   @Published var toTime = {
//      var components = DateComponents()
//      components.hour = 17
//      components.minute = 0
//      return Cal.date(from: components) ?? Date()
//   }()
//}

struct NotificationSelection: View {
   
   @Environment(\.colorScheme) var scheme
   @Environment(\.managedObjectContext) var moc
   
   @ObservedObject var habit: Habit
   
   @State private var animateBell = false
//
   @State private var selectFrequency = false
   
   private var textColor: Color {
      scheme == .light ? .white : .black
   }
   
   func deleteNotification(from source: IndexSet) {
      guard let index = source.first else { return }
      let notifToBeDeleted = habit.notificationsArray[index]
      habit.removeFromNotifications(notifToBeDeleted)
      habit.removeAllNotifications(notifs: [notifToBeDeleted])
      moc.delete(notifToBeDeleted)
      moc.fatalSave()
   }
   
   func requestNotifPermission() {
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
         if success {
            print("Notification permission granted!")
         } else if let error = error {
            print(error.localizedDescription)
         }
      }
   }
   
   var body: some View {
      let _ = Self.printChanges(self)
//      print("Notification selection updating, habit.notificationsArray = \(habit.notificationsArray)")
      return (
      Background {
         VStack(spacing: 10) {
            
            AnimatedHabitCreationHeader(animateBell: $animateBell,
                                        title: "Reminder",
                                        subtitle: "Add a reminder to complete your habit.")
            
            Menu {
               Button {
                  animateBell.toggle()
                  let notif = SpecificTimeNotification(context: moc, time: Date())
                  requestNotifPermission()
                  habit.addToNotifications(notif)
//                  habit.addNotification(notif)
               } label: {
                  Label("Specific Time", systemImage: "clock")
               }

               Button {
                  animateBell.toggle()
                  let notif = RandomTimeNotification(myContext: moc)
                  requestNotifPermission()
                  habit.addToNotifications(notif)
//                  habit.addNotification(notif)
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
            
            if !habit.notificationsArray.isEmpty {
               VStack {
                  List {
                     Section {
                        ForEach(0 ..< habit.notificationsArray.count, id: \.self) { i in
                           let notification = habit.notificationsArray[i]
                           NotificationRow(notification: notification, index: i)
                              .listRowBackground(Color.cardColor)
                              .listRowSeparatorTint(.gray, edges: .bottom)
                              .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
                                 return -20
                              }
                        }
                        .onDelete(perform: deleteNotification)
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
                  .animation(.easeInOut, value: habit.notifications)
               }
            }
            Spacer()
         }
      }
      )
   }
}

struct MyViewNotificationSelection_Previewer: View {
   @State private var notifications: [Notification] = []
   
   func data() -> Habit {
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
   
   var body: some View {
      let habit = data()
      return (
         Background {
            NotificationSelection(habit: habit)
         }
      )
   }
}

struct NotificationSelection_Previews: PreviewProvider {
   static var previews: some View {
      MyViewNotificationSelection_Previewer()
   }
}

struct SpecificTimeNotificationRow: View {
   
   @ObservedObject var notification: SpecificTimeNotification
   
   var timeBinding: Binding<Date> {
      return Binding {
         notification.time ?? Date()
      } set: { newDate, _ in
         notification.time = newDate
      }
   }
   
   var body: some View {
      HStack {
         Spacer()
         Text("Every day at ")
         if notification.time != nil {
            JustDatePicker(time: timeBinding)
         }
         Spacer()
      }
      .padding(.vertical, 1)
   }
}

struct RandomTimeNotificationRow: View {
   
   @ObservedObject var notification: RandomTimeNotification
   
   var startTimeBinding: Binding<Date> {
      return Binding {
         notification.startTime ?? Date()
      } set: { newDate, _ in
         notification.startTime = newDate
      }
   }
   
   var endTimeBinding: Binding<Date> {
      return Binding {
         notification.endTime ?? Date()
      } set: { newDate, _ in
         notification.endTime = newDate
      }
   }
   
   var body: some View {
      VStack {
         Text("Random time between")
         HStack {
            Spacer()
            JustDatePicker(time: startTimeBinding)
            Text(" and ")
            JustDatePicker(time: endTimeBinding)
            Spacer()
         }
      }
   }
}

struct NotificationRow: View {
   
   @EnvironmentObject var habit: Habit
   
   @ObservedObject var notification: Notification
   
   var index: Int
   
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
      .onChange(of: notification) { newValue in
         print("Notification updated!!!!!")
//         habit.addNotification(newValue)
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
