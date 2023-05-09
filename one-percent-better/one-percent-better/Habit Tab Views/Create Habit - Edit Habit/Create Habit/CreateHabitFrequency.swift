//
//  CreateHabitFrequency.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 8/9/22.
//

import SwiftUI
import CoreData

enum ChooseFrequencyRoute: Hashable {
   case next(Habit, HabitFrequency)
}

enum HabitFrequencyError: Error {
   case zeroFrequency
   case emptyFrequency
}

struct CreateHabitFrequency: View {
   
   @Environment(\.managedObjectContext) var moc
   
   @ObservedObject var nav = HabitTabNavPath.shared
   
   var habit: Habit
   
   @State private var frequencySelection: HabitFrequency = .timesPerDay(1)
   
   @Binding var hideTabBar: Bool
   
   @State private var isGoingToNotifications = false
   
   var body: some View {
      Background {
         VStack {
            Spacer()
               .frame(height: 20)
            HabitCreationHeader(systemImage: "clock.arrow.2.circlepath",
                                title: "Frequency",
                                subtitle: "How often do you want to complete this habit?")
            
            FrequencySelectionStack(selection: $frequencySelection)
            
            Spacer()
            
//            NavigationLink(value: ChooseFrequencyRoute.next(habit, frequencySelection)) {
//               BottomButton(label: "Next")
//            }
            
            Button {
               isGoingToNotifications = true
               nav.path.append(ChooseFrequencyRoute.next(habit, frequencySelection))
            } label: {
               BottomButton(label: "Next")
            }
         }
         .navigationDestination(for: ChooseFrequencyRoute.self) { [nav] route in
            if case let .next(habit, habitFrequency) = route {
               CreateHabitNotifications(habit: habit, habitFrequency: habitFrequency, hideTabBar: $hideTabBar)
            }
         }
      }
      .onAppear {
         isGoingToNotifications = false
      }
      .onDisappear {
         if !isGoingToNotifications {
            Task {
               moc.perform {
                  moc.delete(habit)
               }
            }
         }
      }
      .toolbar(.hidden, for: .tabBar)
   }
}

struct HabitFrequency_Previews: PreviewProvider {
   
   static func data() -> Habit {
      let context = CoreDataManager.previews.mainContext
      
      let day0 = Date()
      let day1 = Cal.date(byAdding: .day, value: -1, to: day0)!
      let day2 = Cal.date(byAdding: .day, value: -2, to: day0)!
      
      let h1 = try? Habit(context: context, name: "Horseback Riding")
      h1?.markCompleted(on: day0)
      h1?.markCompleted(on: day1)
      h1?.markCompleted(on: day2)
      
      let habits = Habit.habits(from: context)
      return habits.first!
   }
   
   static var previews: some View {
      CreateHabitFrequency(habit: data(), hideTabBar: .constant(true))
   }
}
