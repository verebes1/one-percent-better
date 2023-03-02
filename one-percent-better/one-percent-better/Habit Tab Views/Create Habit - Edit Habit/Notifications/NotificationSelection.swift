//
//  NotificationSelection.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/14/22.
//

import SwiftUI

enum NotificationType: Identifiable, Equatable {
   //   var id: ObjectIdentifier
   
   
   var id: UUID {
      switch self {
      case .specificTimeDaily(_, let id):
         return id
      case .randomTimeDaily(_, _, let id):
         return id
      }
   }
   
   case specificTimeDaily(time: Date, id: UUID)
   case randomTimeDaily(from: Date, to: Date, id: UUID)
   //   case specificDayAndTimeWeekly
   //   case randomTimeWeekly
}

struct NotificationSelection: View {
   
   @State private var sendNotif = false
   @State private var timeSelection: Date = Date()
   @State private var animateBell = false
   
   @State private var frequencySelection: String = "Test"
   
   @State private var selectFrequency = false
   
   @State private var notifications: [NotificationType] = [.specificTimeDaily(time: Date(), id: UUID()), .randomTimeDaily(from: Date(), to: Date(), id: UUID())]
   
   func deleteNotification(from source: IndexSet) {
      notifications.remove(atOffsets: source)
   }
   
   var body: some View {
      Background {
         VStack(spacing: 10) {
            
            AnimatedHabitCreationHeader(animateBell: $animateBell,
                                        title: "Reminder",
                                        subtitle: "Add a reminder to complete your habit.")
            
            Menu {
               Button("Specific Time") {
                  animateBell = true
                  notifications.append(NotificationType.specificTimeDaily(time: Date(), id: UUID()))
               }
               Button("Random Time") {
                  animateBell = true
                  notifications.append(NotificationType.randomTimeDaily(from: Date(), to: Date(), id: UUID()))
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
                  }
               }
               .background(Color.cardColor)
               .cornerRadius(radius: 10)
               .padding(.horizontal, 20)
            }
            
            if !notifications.isEmpty {
               VStack {
                  List {
                     Section {
                        ForEach(notifications) { notification in
                           switch notification {
                           case .specificTimeDaily:
                              DatePicker(selection: $timeSelection, displayedComponents: [.hourAndMinute]) {
                                 Text("Every day at ")
                              }
                              .frame(height: 37)
                              .listRowBackground(Color.cardColor)
                           case .randomTimeDaily:
                              VStack {
                                 DatePicker("Random time between ", selection: $timeSelection, displayedComponents: [.hourAndMinute])
                                 HStack {
//                                    DatePicker(selection: $timeSelection, displayedComponents: [.hourAndMinute])
                                    
                                    
//                                    .frame(height: 37)
                                    DatePicker(selection: $timeSelection, displayedComponents: [.hourAndMinute]) {
                                       Text(" and ")
                                    }
                                 }
                              }
                              .listRowBackground(Color.cardColor)
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
                  .animation(.easeInOut, value: notifications)
                  
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
      .onChange(of: timeSelection) { newTime in
         
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
