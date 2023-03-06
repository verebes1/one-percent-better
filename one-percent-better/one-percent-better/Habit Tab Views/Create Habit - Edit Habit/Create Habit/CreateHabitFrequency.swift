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
   
   @EnvironmentObject var nav: HabitTabNavPath
   
   var habit: Habit
   
   @State private var frequencySelection: HabitFrequency = .timesPerDay(1)
   
   @Binding var hideTabBar: Bool
   
//   init(moc: NSManagedObjectContext, habitName: String, hideTabBar: Binding<Bool>) {
//      self._hideTabBar = hideTabBar
//      self.habit = Habit(moc: moc, name: habitName, id: UUID())
//   }
   
   var body: some View {
      Background {
         VStack {
            Spacer()
               .frame(height: 20)
            HabitCreationHeader(systemImage: "clock.arrow.2.circlepath",
                                title: "Frequency",
                                subtitle: "How often do you want to complete this habit?")
            
//            Spacer().frame(height: 20)
            
            FrequencySelectionStack(selection: $frequencySelection)
            
            Spacer()
            
            NavigationLink(value: ChooseFrequencyRoute.next(habit, frequencySelection)) {
               BottomButton(label: "Next")
            }
         }
         .toolbar(.hidden, for: .tabBar)
         .navigationDestination(for: ChooseFrequencyRoute.self) { [nav] route in
            if case let .next(habit, habitFrequency) = route {
               let _ = habit.changeFrequency(to: habitFrequency)
               CreateHabitNotifications(habit: habit, hideTabBar: $hideTabBar)
                  .environmentObject(nav)
            }
         }
      }
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
