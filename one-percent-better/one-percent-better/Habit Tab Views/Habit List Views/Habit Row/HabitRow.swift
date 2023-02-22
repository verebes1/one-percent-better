//
//  HabitRow.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 7/29/22.
//

import SwiftUI
import Combine
import CoreData

class HabitRowViewModel: NSObject, NSFetchedResultsControllerDelegate, ObservableObject {
   
   let habitController: NSFetchedResultsController<Habit>
   let moc: NSManagedObjectContext
   
   @Published var habit: Habit
   
   var currentDay: Date
   
   @Published var timerLabel: String = "00:00"
   @Published var isTimerRunning: Bool
   var hasTimeTracker: Bool
   var hasTimerStarted: Bool
   
   init(moc: NSManagedObjectContext, habit: Habit, currentDay: Date) {
//      print("initializing new habitRow: \(habit.name)")
      //      self.habit = habit.copy() as? Habit
      self.habit = habit
      self.currentDay = currentDay
      isTimerRunning = false
      hasTimeTracker = false
      hasTimerStarted = false
      self.currentDay = currentDay
      
      let sortDescriptors = [NSSortDescriptor(keyPath: \Habit.orderIndex, ascending: true)]
      habitController = Habit.resultsController(context: moc,
                                                sortDescriptors: sortDescriptors,
                                                predicate: NSPredicate(format: "id == %@", habit.id as CVarArg))
      self.moc = moc
      super.init()
      habitController.delegate = self
      try? habitController.performFetch()
      
      if let t = self.habit.timeTracker {
         t.callback = updateTimerString(to:)
         isTimerRunning = t.isRunning
         hasTimeTracker = true
         if let value = t.getValue(on: self.currentDay) {
            self.updateTimerString(to: value)
            if value != 0 {
               hasTimerStarted = true
            }
         }
      }
   }
   
   func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
      print("JJJJ habit row changing!!! for habit: \(habit.name)")
      objectWillChange.send()
   }
   
   var firstResult: Habit? {
      let results = habitController.fetchedObjects ?? []
      if results.isEmpty {
         return nil
      } else {
         return results[0]
      }
   }
   
   //   func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
   //      let results = controller.fetchedObjects ?? []
   //
   //      if let fetchedHabit = firstResult {
   ////         habit != fetchedHabit {
   //         let habitDays = habit.daysCompleted
   //         let fetchedDays = fetchedHabit.daysCompleted
   //         print("New update for fetched habit \(fetchedHabit.name)")
   //         print("habit days: \(habitDays)")
   //         print("fetched days: \(fetchedDays)")
   //         self.habit = fetchedHabit
   //      }
   //   }
   
   //   func controller(
   //       _ controller: NSFetchedResultsController<NSFetchRequestResult>,
   //       didChange anObject: Any,
   //       at indexPath: IndexPath?,
   //       for type: NSFetchedResultsChangeType,
   //       newIndexPath: IndexPath?
   //   ) {
   //      print("changing object!")
   //      objectWillChange.send()
   //   }
   
   var notDoneIn: Int {
      var difference = 0
      var day = Cal.startOfDay(for: currentDay)
      day = Cal.date(byAdding: .day, value: -1, to: day)!
      if day > habit.startDate {
         while !habit.wasCompleted(on: day) {
            difference += 1
            day = Cal.date(byAdding: .day, value: -1, to: day)!
            if day < habit.startDate {
               break
            }
         }
         return difference
      } else {
         return -1
      }
   }
   
   func streakLabel() -> (String, Color) {
      let gray = Color(hue: 1.0, saturation: 0.0, brightness: 0.519)
      let streak = habit.streak(on: currentDay)
      if streak > 0 {
         var timePeriodText: String
         guard let freq = habit.frequency(on: currentDay) else {
            return ("Error", .red)
         }
         switch freq {
         case .timesPerDay, .daysInTheWeek:
            timePeriodText = "day"
         case .timesPerWeek:
            timePeriodText = "week"
         }
         return ("\(streak) \(timePeriodText) streak", .green)
      } else if let days = habit.notDoneInDays(on: currentDay) {
         let dayText = days == 1 ? "day" : "days"
         return ("Not done in \(days) \(dayText)", .red)
      } else {
         return ("No streak", gray)
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
   
   init(moc: NSManagedObjectContext, habit: Habit, day: Date) {
      self.vm = HabitRowViewModel(moc: moc, habit: habit, currentDay: day)
   }
   
   var body: some View {
//      print("   - HabitRow(\(vm.habit.name)) body")
//      let _ = Self._printChanges()
      return (
         ZStack {
            // Actual row views
            HStack(spacing: 0) {
               Spacer().frame(width: 15)
               HabitCompletionCircle(vm: vm,
                                     size: 28,
                                     completedPressed: $completePressed)
               Spacer().frame(width: 15)
               HabitRowLabels()
                  .environmentObject(vm)
               
               Spacer()
               ImprovementGraphView()
                  .environmentObject(vm)
                  .frame(width: 80, height: 35)
                  .padding(.trailing, 20)
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
//            .background(Color.random)
      )
   }
}

struct HabitRowPreviewer: View {
   
   @ObservedObject var vm: HabitListViewModel
   
   @State private var currentDay = Date()
   
   @StateObject var nav = HabitTabNavPath()
   
   var body: some View {
      NavigationStack {
         Background {
            List {
               ForEach(Array(zip(vm.habits.indices, vm.habits)), id:\.0) { index, habit in
                  NavigationLink(value: habit) {
                     HabitRow(moc: CoreDataManager.previews.mainContext, habit: habit, day: currentDay)
                        .environmentObject(habit)
                  }
                  .listRowInsets(.init(top: 0,
                                       leading: 0,
                                       bottom: 0,
                                       trailing: 20))
               }
            }
            .environment(\.defaultMinListRowHeight, 54)
         }
         .environmentObject(nav)
      }
   }
}

struct HabitRow_Previews: PreviewProvider {
   
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
      h2?.changeFrequency(to: .daysInTheWeek([2,3,5]))
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
      
      let in3daysWeedayInt = (Date().weekdayInt + 4) % 7
      let in3DaysWeekday = Weekday(rawValue: in3daysWeedayInt)!
      let h5 = try? Habit(context: context, name: "3 tpw, reset in 3, done 2", frequency: .timesPerWeek(times: 3, resetDay: in3DaysWeekday), id: id5)
      
      h5?.markCompleted(on: Cal.add(days: -1))
      h5?.markCompleted(on: Cal.add(days: -2))
      
      let habits = Habit.habits(from: context)
      return habits
   }
   
   static var previews: some View {
      let _ = data()
      let moc = CoreDataManager.previews.mainContext
      HabitRowPreviewer(vm: HabitListViewModel(moc))
   }
}
