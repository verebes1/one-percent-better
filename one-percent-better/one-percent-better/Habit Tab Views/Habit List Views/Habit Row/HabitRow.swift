//
//  HabitRow.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 7/29/22.
//

import SwiftUI
import Combine

class HabitRowViewModel: ObservableObject {
   let habit: Habit
   let currentDay: Date
   @Published var timerLabel: String = "00:00"
   @Published var isTimerRunning: Bool
   var hasTimeTracker: Bool
   var hasTimerStarted: Bool
   
   init(habit: Habit, currentDay: Date) {
      self.habit = habit
      self.currentDay = currentDay
      isTimerRunning = false
      hasTimeTracker = false
      hasTimerStarted = false
      if let t = habit.timeTracker {
         t.callback = updateTimerString(to:)
         isTimerRunning = t.isRunning
         hasTimeTracker = true
         if let value = t.getValue(on: currentDay) {
            self.updateTimerString(to: value)
            if value != 0 {
               hasTimerStarted = true
            }
         }
      }
   }
   
   /// Current streak (streak = 1 if completed today, streak = 2 if completed today and yesterday, etc.)
   var streak: Int {
      get {
         var streak = 0
         // start at yesterday, a streak is only broken if it's not completed by the end of the day
         var day = Calendar.current.date(byAdding: .day, value: -1, to: currentDay)!
         while habit.wasCompleted(on: day) {
            streak += 1
            day = Calendar.current.date(byAdding: .day, value: -1, to: day)!
         }
         // add 1 if completed today
         if habit.wasCompleted(on: currentDay) {
            streak += 1
         }
         return streak
      }
   }
   
   var notDoneIn: Int {
      var difference = 0
      var day = Calendar.current.startOfDay(for: currentDay)
      day = Calendar.current.date(byAdding: .day, value: -1, to: day)!
      if day > habit.startDate {
         while !habit.wasCompleted(on: day) {
            difference += 1
            day = Calendar.current.date(byAdding: .day, value: -1, to: day)!
            if day < habit.startDate {
               break
            }
         }
         return difference
      } else {
         return -1
      }
   }
   
   /// Streak label used in habit view
   var streakLabel: String {
      if streak > 0 {
         return "\(streak) day streak"
      } else if habit.daysCompleted.isEmpty || notDoneIn == -1 {
         return "Never done"
      } else {
         let diff = notDoneIn
         let dayText = diff == 1 ? "day" : "days"
         return "Not done in \(diff) \(dayText)"
      }
   }
   
   /// Color of streak label used in habit view
   var streakLabelColor: Color {
      if streak > 0 {
         return .green
      } else if habit.daysCompleted.isEmpty || notDoneIn == -1 {
         return Color(hue: 1.0, saturation: 0.0, brightness: 0.519)
      } else {
         return .red
      }
   }
   
   func getTimerString(from time: Int) -> String {
      var seconds = "\(time % 60)"
      if time % 60 < 10 {
         seconds = "0" + seconds
      }
      var minutes = "\((time / 60) % 60)"
      if (time / 60) % 60 < 10 {
         minutes = "0" + minutes
      }
      return minutes + ":" + seconds
   }
   
   func updateTimerString(to value: Int) {
      self.timerLabel = getTimerString(from: value)
      
      if let t = habit.timeTracker {
         if value >= t.goalTime {
            habit.markCompleted(on: currentDay)
         }
      }
   }
   
   var timePercentComplete: Double {
      guard let t = habit.timeTracker else {
         return 0
      }
      guard let soFar = t.getValue(on: currentDay) else {
         return 0
      }
      return Double(soFar) / Double(t.goalTime)
   }
   
}

struct HabitRow: View {
   
   @Environment(\.scenePhase) var scenePhase
   
   @ObservedObject var vm: HabitRowViewModel
   
   @State private var completePressed = false
   
   init(habit: Habit, day: Date) {
      self.vm = HabitRowViewModel(habit: habit, currentDay: day)
   }
   
   var body: some View {
      ZStack {
         // Actual row views
         HStack {
            HabitCompletionCircle(vm: vm,
                                  size: 28,
                                  completedPressed: $completePressed)
            HabitRowLabels(vm: vm)
            Spacer()
            //                ListChevron()
         }
         .listRowBackground(vm.isTimerRunning ? Color.green.opacity(0.1) : Color.white)
         
         // Left side of habit row is completion button
         GeometryReader { geo in
            Color.clear
               .contentShape(Path(CGRect(origin: .zero, size: CGSize(width: geo.size.width / 3, height: geo.size.height))))
               .onTapGesture {
                  completePressed.toggle()
               }
         }
      }
   }
}

struct HabitRowPreviewer: View {
   
   @ObservedObject var vm: HabitListViewModel
   
   var body: some View {
      NavigationView {
         Background {
            List {
               ForEach(vm.habits, id:\.name) { habit in
                  HabitRow(habit: habit, day: Date())
                     .environmentObject(habit)
               }
            }
            .environment(\.defaultMinListRowHeight, 54)
         }
      }
   }
}

struct HabitRow_Previews: PreviewProvider {
   
   static func data() -> [Habit] {
      let context = CoreDataManager.previews.mainContext
      
      let day0 = Date()
      let h1 = try? Habit(context: context, name: "Swimming")
      h1?.markCompleted(on: day0)
      
      let _ = try? Habit(context: context, name: "Basketball")
      
      let h3 = try? Habit(context: context, name: "Timed Habit")
      
      if let h3 = h3 {
         let _ = TimeTracker(context: context, habit: h3, goalTime: 10)
      }
      
      let _ = try? Habit(context: context, name: "Twice A Day", frequency: .timesPerDay(2))
      
      let habits = Habit.habits(from: context)
      return habits
   }
   
   static var previews: some View {
      let _ = data()
      let moc = CoreDataManager.previews.mainContext
      HabitRowPreviewer(vm: HabitListViewModel(moc))
   }
}

struct ListChevron: View {
   var body: some View {
      Image(systemName: "chevron.right")
         .resizable()
         .aspectRatio(contentMode: .fit)
         .frame(height: 12)
         .foregroundColor(.gray)
         .padding(.trailing, 5)
   }
}

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
