//
//  HabitRowLabels.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 2/12/23.
//

import SwiftUI

struct HabitRowSubLabel: ViewModifier {
   
   var color: Color
   
   func body(content: Content) -> some View {
      content
         .font(.system(size: 11))
         .foregroundColor(color)
   }
}

extension View {
   func subLabel(color: Color) -> some View {
      modifier(HabitRowSubLabel(color: color))
   }
}

struct HabitRowLabels: View {
   
   @EnvironmentObject var vm: HabitRowViewModel
   
//   @State private var streakLabel: (String, Color) = ("", Color.clear)
   
   let subGray = Color(hue: 1.0, saturation: 0.0, brightness: 0.519)
   
   func specificWeekdaysLabel(days: [Weekday]) -> String {
      if days.contains(Weekday(Date())) {
         return "Due today"
      }
      
      var finalString = "Due on "
      let dayString = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
      for (i, day) in days.enumerated() {
         finalString += "\(dayString[day.rawValue])"
         if i != days.count - 1 {
            finalString += ", "
         }
      }
      return finalString
   }
   
   var body: some View {
      VStack(alignment: .leading) {
         
         HStack {
            Text(vm.habit.name)
               .font(.system(size: 16))
//               .fontWeight(vm.isTimerRunning ? .bold : .regular)
            
            if case .timesPerDay(let tpd) = vm.habit.frequency(on: vm.currentDay),
               tpd > 1 {
               TimesCompletedIndicator(timesCompleted: vm.habit.timesCompleted(on: vm.currentDay), timesExpected: tpd)
            } else if case .timesPerWeek(times: let tpw, _) = vm.habit.frequency(on: vm.currentDay) {
               TimesCompletedIndicator(timesCompleted: vm.habit.timesCompletedThisWeek(on: vm.currentDay, upTo: true), timesExpected: tpw)
            }
         }
         
         HStack(spacing: 0) {
            // Time Tracker
            /*
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
             */
            let streakLabel = vm.streakLabel()
            Text(streakLabel.0)
               .subLabel(color: streakLabel.1)
         }
         
         switch vm.habit.frequency(on: vm.currentDay) {
         case .timesPerDay(_):
            EmptyView()
         case .specificWeekdays(let days):
            Text(specificWeekdaysLabel(days: days))
               .subLabel(color: subGray)
         case .timesPerWeek(_, resetDay: let resetDay):
            let finalString = "Due by \(resetDay)"
            Text(finalString)
               .subLabel(color: subGray)
         case .none:
            EmptyView()
         }
//         if case .specificWeekdays(_) = vm.habit.frequency(on: vm.currentDay),
//            !vm.habit.isDue(on: vm.currentDay) {
//            Text("Not due today")
//               .font(.system(size: 11))
//               .foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.519))
//         } else {
      }
   }
}


struct TimesCompletedIndicator: View {
   
   var timesCompleted: Int
   var timesExpected: Int
   
   var body: some View {
      HStack {
         Text("\(timesCompleted) / \(timesExpected)")
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
}


struct HabitRowLabels_Previews: PreviewProvider {
   
   static let id1 = UUID()
   static let id2 = UUID()
   static let id3 = UUID()
   static let id4 = UUID()
   static let id5 = UUID()
   
   static func data() -> [Habit] {
      let context = CoreDataManager.previews.mainContext
      
      let h1 = try? Habit(context: context, name: "Swimming", id: id1)
      h1?.markCompleted(on: Cal.date(byAdding: .day, value: -3, to: Date())!)
      h1?.markCompleted(on: Cal.date(byAdding: .day, value: 0, to: Date())!)
      h1?.markCompleted(on: Cal.date(byAdding: .day, value: -1, to: Date())!)
      
      let h2 = try? Habit(context: context, name: "Basketball (MWF)", id: id2)
      h2?.changeFrequency(to: .specificWeekdays([.tuesday, .wednesday, .friday]))
      h2?.markCompleted(on: Cal.add(days: -1))
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
      
      let in3daysWeedayInt = (Date().weekdayInt + 3) % 7
      let in3DaysWeekday = Weekday(in3daysWeedayInt)
      let h5 = try? Habit(context: context, name: "3 times a week, reset in 3 days, completed twice", frequency: .timesPerWeek(times: 3, resetDay: in3DaysWeekday), id: id5)
      
      h5?.markCompleted(on: Cal.add(days: -1))
      h5?.markCompleted(on: Cal.add(days: -2))
      
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
            HabitRowLabels()
               .environmentObject(HabitRowViewModel(moc: moc, habit: habit, currentDay: Date()))
               .padding(.leading, 20)
               .border(.black)
            Divider()
         }
      }
   }
}
