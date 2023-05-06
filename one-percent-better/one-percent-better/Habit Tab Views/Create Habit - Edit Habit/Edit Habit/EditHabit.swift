//
//  EditHabit.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 6/22/22.
//

import SwiftUI
import CoreData

enum EditHabitNavRoute: Hashable {
   case editFrequency(Habit)
   case editNotification(Habit)
   case editTracker(Habit, Tracker)
}

class EditHabitModel: HabitConditionalFetcher {
   
   @Published var habit: Habit
   
   init(moc: NSManagedObjectContext = CoreDataManager.shared.mainContext, habit: Habit) {
      self.habit = habit
      super.init(moc, predicate: NSPredicate(format: "id == %@", habit.id as CVarArg))
   }
   
   override func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
      guard let newHabits = controller.fetchedObjects as? [Habit] else { return }
      guard !newHabits.isEmpty else { return }
      habit = newHabits.first!
   }
   
   func deleteHabit() {
      // Remove the item to be deleted
      moc.delete(habit)
      
      // Update order indices
      let _ = Habit.habits(from: moc)
      
      moc.assertSave()
   }
}

struct EditHabit: View {
   
   @Environment(\.managedObjectContext) var moc
   @Environment(\.presentationMode) var presentationMode
   
   @EnvironmentObject var nav: HabitTabNavPath
   
   @ObservedObject var vm: EditHabitModel
   @State private var newHabitName: String
   
   /// Show empty habit name error if trying to save with empty habit name
   @State private var emptyHabitNameError = false
   @State private var startDate: Date
   @State private var confirmDeleteHabit: Bool = false
   @State private var isGoingToDelete = false
   
   
   
   enum EditHabitError: Error {
      case emptyHabitName
   }
   
   init(habit: Habit) {
      self.vm = EditHabitModel(habit: habit)
      self._newHabitName = State(initialValue: habit.name)
      self._startDate = State(initialValue: habit.startDate)
   }
   
   /// Check if the user can save or needs to make changes
   /// - Returns: True if can save, false if changes needed
   func canSave() throws -> Bool {
      if newHabitName.isEmpty || newHabitName == "" || newHabitName.trimmingCharacters(in: .whitespaces).isEmpty {
         throw EditHabitError.emptyHabitName
      }
      return true
   }
   
   var freqTextView: some View {      
      switch habit.frequency(on: Date()) {
      case .timesPerDay(let n):
         let timesString = n == 1 ? "time" : "times"
         return Text("\(n) \(timesString) per day")
      case .specificWeekdays(let days):
         var finalString = ""
         let dayString = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
         for (i, day) in days.enumerated() {
            finalString += "\(dayString[day.rawValue])"
            if i != days.count - 1 {
               finalString += ", "
            }
         }
         return Text(finalString)
      case .timesPerWeek(times: let n, resetDay: let resetDay):
         let timesString = n == 1 ? "time" : "times"
         let finalString = "\(n) \(timesString) per week, every \(resetDay)"
         return Text(finalString)
      case .none:
         return Text("Unknown frequency")
      }
   }
   
   var body: some View {
      let _ = Self._printChanges()
      return (
      Background {
         VStack {
            List {
               Section(header: Text("Habit")) {
                  EditHabitName(newHabitName: $newHabitName,
                                emptyNameError: $emptyHabitNameError)
                  
                  // MARK: - Edit Frequency
                  
                  NavigationLink(value: EditHabitNavRoute.editFrequency(habit)) {
                     HStack {
                        Text("Frequency")
                           .fontWeight(.medium)
                        
                        Spacer()
                        
                        freqTextView
                     }
                  }
                  
                  // MARK: - Edit Notifications
                  
                  NavigationLink(value: EditHabitNavRoute.editNotification(habit)) {
                     HStack {
                        Text("Notifications")
                           .fontWeight(.medium)
                        
                        Spacer()
                        
                        EditHabitNotificationRow(count: habit.notificationsArray.count)
                     }
                  }
                  
                  // MARK: - Edit Start Date
                  
                  HStack {
                     Text("Start date")
                        .fontWeight(.medium)
                     Spacer()
                     
                     let range = Cal.add(days: -10000) ... (habit.firstCompleted ?? Date())
                     DatePicker("", selection: $startDate, in: range, displayedComponents: [.date])
                        .frame(height: 50)
                  }
                  .onChange(of: startDate) { newValue in
                     habit.updateStartDate(to: newValue)
                  }
                                    
               }
               .listRowBackground(Color.cardColor)
               
               if habit.editableTrackers.count > 0 {
                  Section(header: Text("Trackers")) {
                     ForEach(0 ..< habit.editableTrackers.count, id: \.self) { i in
                        let tracker = habit.editableTrackers[i]
                        NavigationLink(value: EditHabitNavRoute.editTracker(habit, tracker)) {
                           EditTrackerRow(tracker: tracker)
//                           EditTrackerRowSimple(name: tracker.name)
                        }
                     }
                  }
                  .listRowBackground(Color.cardColor)
               }
               
               Section {
                  Button {
                     confirmDeleteHabit = true
                  } label: {
                     HStack {
                        Text("Delete Habit")
                           .foregroundColor(.red)
                        Spacer()
                        Image(systemName: "trash")
                           .foregroundColor(.red)
                     }
                  }
                  .alert(
                     "Are you sure you want to delete your habit \"\(habit.name)\"?",
                     isPresented: $confirmDeleteHabit
                  ) {
                     Button("Delete", role: .destructive) {
                        nav.path.removeLast(2)
                        isGoingToDelete = true
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//                           deleteHabit()
//                        }
                     }
                     
                  }
               }
               .listRowBackground(Color.cardColor)
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
         }
         .navigationTitle("Edit Habit")
         .navigationBarTitleDisplayMode(.inline)
         .navigationDestination(for: EditHabitNavRoute.self) { [nav] route in
            if case let .editFrequency(habit) = route {
               EditHabitFrequency(habit: habit)
            }
            
            if case let .editTracker(habit, tracker) = route {
               EditTracker(habit: habit, tracker: tracker)
                  .environmentObject(nav)
            }
            
            if case let .editNotification(habit) = route {
               EditHabitNotifications(habit: habit)
                  .environmentObject(nav)
            }
         }
         .onDisappear {
            if !isGoingToDelete {
               do {
                  if try canSave() && newHabitName != habit.name {
                     habit.updateName(to: newHabitName)
                     moc.perform {
                        self.moc.assertSave()
                     }
                  }
               } catch {
                  // do nothing
               }
            } else {
               deleteHabit()
            }
         }
      }
      )
   }
}

struct EditHabitPreviewer: View {
   let habit: Habit
   @StateObject private var nv = HabitTabNavPath()
   
   
   var body: some View {
      NavigationStack(path: $nv.path) {
         EditHabit(habit: habit)
            .environmentObject(nv)
      }
   }
}

struct EditHabit_Previews: PreviewProvider {
   
   static func data() -> Habit {
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
   
   static var previews: some View {
      let habit = data()
      NavigationView {
         EditHabitPreviewer(habit: habit)
//         EditHabit(habit: habit)
      }
   }
}

struct EditTrackerRowSimple: View {
   
   var name: String
   
   var body: some View {
      HStack {
         Text(name)
         Spacer()
      }
   }
}

struct EditTrackerRow: View {
   
   var tracker: Tracker
   
   var body: some View {
      HStack {
         if tracker is GraphTracker {
            IconTextRow(title: tracker.name, icon: "chart.xyaxis.line", color: .blue)
         } else if tracker is ImageTracker {
            IconTextRow(title: tracker.name, icon: "photo", color: .mint)
         } else if tracker is ExerciseTracker {
            IconTextRow(title: tracker.name, icon: "figure.walk", color: .red)
         } else {
            Text(tracker.name)
            //            IconTextRow(title: tracker.name, icon: "chart.xyaxis.line", color: .blue)
         }
         Spacer()
      }
   }
}

struct EditHabitName: View {
   
   @Binding var newHabitName: String
   @Binding var emptyNameError: Bool
   
   var body: some View {
      VStack {
         HStack {
            Text("Name")
               .fontWeight(.medium)
//            IconTextRow(title: "Name", icon: "square.and.pencil", color: .systemTeal)
//               .fontWeight(.medium)
            TextField("", text: $newHabitName)
               .multilineTextAlignment(.trailing)
               .frame(height: 30)
         }
         ErrorLabel(message: "Habit name can't be empty",
                    showError: $emptyNameError)
      }
   }
}

struct EditHabitNotificationRow: View {
   
   var count: Int
   
   var label: String {
      count == 0 ? "None" : "\(count)"
   }
   
   var body: some View {
      Text(label)
         .foregroundColor(count == 0 ? .secondaryLabel : .primary)
   }
}
