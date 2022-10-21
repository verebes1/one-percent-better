//
//  EditHabit.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 6/22/22.
//

import SwiftUI

enum EditHabitNavRoute: Hashable {
   case editFrequency
   case editTracker(Tracker)
}

struct EditHabit: View {
   
   @Environment(\.managedObjectContext) var moc
   @Environment(\.presentationMode) var presentationMode
   
   @EnvironmentObject var habit: Habit
   @EnvironmentObject var nav: HabitTabNavPath
   
   @State private var newHabitName: String
   
   /// Show empty habit name error if trying to save with empty habit name
   @State private var emptyHabitNameError = false
   
   @State private var editFrequencyPresenting = false
   
   enum EditHabitError: Error {
      case emptyHabitName
   }
   
   init(habit: Habit) {
      self._newHabitName = State(initialValue: habit.name)
   }
   
   func deleteHabit() {
      // Remove the item to be deleted
      moc.delete(habit)
      
      // Update order indices
      let _ = Habit.habits(from: moc)
      
      moc.fatalSave()
   }
   
   /// Check if the user can save or needs to make changes
   /// - Returns: True if can save, false if changes needed
   func canSave() throws -> Bool {
      if newHabitName.isEmpty || newHabitName == "" {
         throw EditHabitError.emptyHabitName
      }
      return true
   }
   
   var freqTextView: some View {
      switch habit.frequency(on: Date()) {
      case .timesPerDay(let n):
         return Text("\(n)x daily")
      case .daysInTheWeek(let days):
         var finalString = ""
         let dayString = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
         for (i, day) in days.enumerated() {
            finalString += "\(dayString[day])"
            if i != days.count - 1 {
               finalString += ", "
            }
         }
         return Text(finalString)
      }
   }
   
   var body: some View {
      Background {
         VStack {
            List {
               Section(header: Text("Habit")) {
                  EditHabitName(newHabitName: $newHabitName,
                                emptyNameError: $emptyHabitNameError)
                  
                  NavigationLink(value: EditHabitNavRoute.editFrequency) {
                     HStack {
//                        Text("Frequency")
//                           .fontWeight(.medium)
                        IconTextRow(title: "Frequency", icon: "clock.arrow.2.circlepath", color: .green)
                           .fontWeight(.medium)
                        
                        Spacer()
                        
                        freqTextView
                     }
                  }
                  
               }
               if habit.editableTrackers.count > 0 {
                  Section(header: Text("Trackers")) {
                     ForEach(0 ..< habit.editableTrackers.count, id: \.self) { i in
                        let tracker = habit.editableTrackers[i]
                        NavigationLink(value: EditHabitNavRoute.editTracker(tracker)) {
                           EditTrackerRowSimple(name: tracker.name)
                        }
                     }
                  }
               }
               
               Section {
                  Button {
                     deleteHabit()
                     nav.path.removeLast(2)
                  } label: {
                     HStack {
                        Text("Delete Habit")
                           .foregroundColor(.red)
                        Spacer()
                        Image(systemName: "trash")
                           .foregroundColor(.red)
                     }
                  }
               }
            }
            .listStyle(.insetGrouped)
         }
         .navigationTitle("Edit Habit")
         .navigationBarTitleDisplayMode(.inline)
         .navigationDestination(for: EditHabitNavRoute.self) { route in
            if route == .editFrequency {
               EditHabitFrequency(frequency: habit.frequency(on: Date()))
                  .environmentObject(habit)
            }
            
            if case let .editTracker(tracker) = route {
               EditTracker(habit: habit, tracker: tracker)
            }
         }
         .onDisappear {
            do {
               if try canSave() {
                  habit.name = newHabitName
                  moc.fatalSave()
               }
            } catch {
               // do nothing
            }
         }
      }
   }
}

struct EditHabitPreviewer: View {
   let habit: Habit
   @StateObject private var nv = HabitTabNavPath()
   
   
   var body: some View {
      NavigationStack(path: $nv.path) {
         EditHabit(habit: habit)
            .environmentObject(habit)
            .environmentObject(nv)
      }
   }
}

struct EditHabit_Previews: PreviewProvider {
   
   static func data() -> Habit {
      let context = CoreDataManager.previews.mainContext
      
      let day0 = Date()
      let day1 = Calendar.current.date(byAdding: .day, value: -1, to: day0)!
      let day2 = Calendar.current.date(byAdding: .day, value: -2, to: day0)!
      
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

struct EditHabitName: View {
   
   @Binding var newHabitName: String
   @Binding var emptyNameError: Bool
   
   var body: some View {
      VStack {
         HStack {
//            Text("Name")
//               .fontWeight(.medium)
            IconTextRow(title: "Name", icon: "square.and.pencil", color: .systemTeal)
               .fontWeight(.medium)
            TextField("", text: $newHabitName)
               .multilineTextAlignment(.trailing)
               .frame(height: 30)
         }
         ErrorLabel(message: "Habit name can't be empty",
                    showError: $emptyNameError)
      }
   }
}
