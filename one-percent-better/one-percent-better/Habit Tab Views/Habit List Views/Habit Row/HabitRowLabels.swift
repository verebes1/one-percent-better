//
//  HabitRowLabels.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 2/12/23.
//

import SwiftUI

struct HabitRowLabels: View {
   
   @ObservedObject var vm: HabitRowViewModel
   
   var body: some View {
      VStack(alignment: .leading) {
         
         Text(vm.habit.name)
            .font(.system(size: 16))
            .fontWeight(vm.isTimerRunning ? .bold : .regular)
         
         HStack(spacing: 0) {
            if vm.hasTimeTracker && vm.hasTimerStarted {
               HStack {
                  Text(vm.timerLabel)
                     .font(.system(size: 11))
                     .foregroundColor(.secondaryLabel)
                     .fixedSize()
                     .frame(minWidth: 40)
                     .padding(.horizontal, 4)
                     .background(.gray.opacity(0.1))
                     .cornerRadius(10)
                  
                  Spacer().frame(width: 5)
               }
            }
            
            if case .timesPerDay(let tpd) = vm.habit.frequency(on: vm.currentDay),
               tpd > 1 {
               HStack {
                  Text("\(vm.habit.timesCompleted(on: vm.currentDay)) / \(tpd)")
                     .font(.system(size: 11))
                     .foregroundColor(.secondaryLabel)
                     .fixedSize()
                     .frame(minWidth: 25)
                     .padding(.horizontal, 7)
                     .background(.gray.opacity(0.1))
                     .cornerRadius(5)
                  
                  Spacer().frame(width: 5)
               }
            }
            
            if case .daysInTheWeek(_) = vm.habit.frequency(on: vm.currentDay),
               !vm.habit.isDue(on: vm.currentDay) {
               Text("Not due today")
                  .font(.system(size: 11))
                  .foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.519))
            } else {
               Text(vm.streakLabel)
                  .font(.system(size: 11))
                  .foregroundColor(vm.streakLabelColor)
            }
         }
      }
   }
}



struct HabitRowLabels_Previews: PreviewProvider {
   
   static let id1 = UUID()
   static let id2 = UUID()
   static let id3 = UUID()
   static let id4 = UUID()
   
   static func data() -> [Habit] {
      let context = CoreDataManager.previews.mainContext
      
      let h1 = try? Habit(context: context, name: "Swimming", id: id1)
      h1?.markCompleted(on: Cal.date(byAdding: .day, value: -3, to: Date())!)
      h1?.markCompleted(on: Cal.date(byAdding: .day, value: 0, to: Date())!)
      h1?.markCompleted(on: Cal.date(byAdding: .day, value: -1, to: Date())!)
      
      let h2 = try? Habit(context: context, name: "Basketball (MWF)", id: id2)
      h2?.changeFrequency(to: .daysInTheWeek([2,3,5]))
      h2?.markCompleted(on: Cal.addDays(num: -1))
//      h2?.markCompleted(on: Cal.date(byAdding: .day, value: -3, to: Date())!)
//      h2?.markCompleted(on: Cal.date(byAdding: .day, value: -2, to: Date())!)
//      h2?.markCompleted(on: Cal.date(byAdding: .day, value: -1, to: Date())!)
      
      let h3 = try? Habit(context: context, name: "Timed Habit", id: id3)
      h3?.markCompleted(on: Cal.date(byAdding: .day, value: -3, to: Date())!)
      
      if let h3 = h3 {
         let _ = TimeTracker(context: context, habit: h3, goalTime: 10)
      }
      
      let h4 = try? Habit(context: context, name: "Twice A Day", frequency: .timesPerDay(2), id: id4)
      h4?.markCompleted(on: Cal.date(byAdding: .day, value: -3, to: Date())!)
      h4?.markCompleted(on: Cal.date(byAdding: .day, value: -2, to: Date())!)
      h4?.markCompleted(on: Cal.date(byAdding: .day, value: -2, to: Date())!)
      
      let habits = Habit.habits(from: context)
      return habits
   }
   
   static var previews: some View {
      let _ = data()
      let moc = CoreDataManager.previews.mainContext
      let vm = HabitListViewModel(moc)
      VStack(alignment: .leading, spacing: 20) {
         Divider()
         ForEach(vm.habits) { habit in
            HabitRowLabels(vm: HabitRowViewModel(moc: moc, habit: habit, currentDay: Date()))
               .padding(.leading, 20)
            Divider()
         }
      }
   }
}
