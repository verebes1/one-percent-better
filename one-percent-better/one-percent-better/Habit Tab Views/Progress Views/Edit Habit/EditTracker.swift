//
//  EditTracker.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 8/8/22.
//

import SwiftUI
import CoreData

class EditTrackerModel: TrackerConditionalFetcher {
   @Published var tracker: Tracker

   init(context: NSManagedObjectContext = CoreDataManager.shared.mainContext, tracker: Tracker) {
      self.tracker = tracker
      super.init(context)
   }
   
   override func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
      guard let newTrackers = controller.fetchedObjects as? [Tracker] else { return }
      guard !newTrackers.isEmpty else { return }
      tracker = newTrackers.first!
   }
   
   func delete(habit: Habit) {
      moc.delete(tracker)
      let revisedItems = habit.trackersArray
      
      for reverseIndex in stride(from: revisedItems.count - 1,
                                 through: 0,
                                 by: -1) {
         revisedItems[reverseIndex].index = Int(reverseIndex)
      }
      moc.assertSave()
   }
}

struct EditTracker: View {
   
   @Environment(\.managedObjectContext) var moc
   
//   @EnvironmentObject var nav: HabitTabNavPath
   @EnvironmentObject var vm: ProgressViewModel
   
//   @ObservedObject var tm: EditTrackerModel
   
   @State private var newTrackerName: String
   
   /// Show empty habit name error if trying to save with empty habit name
   @State private var emptyTrackerNameError = false
   @State private var confirmDelete = false
   @State private var isGoingToDelete = false
   
   enum EditTrackerError: Error {
      case emptyTrackerName
   }
   
   init(tracker: Tracker) {
//      tm = EditTrackerModel(tracker: tracker)
      self._newTrackerName = State(initialValue: tracker.name)
   }
   
   /// Check if the user can save or needs to make changes
   /// - Returns: True if can save, false if changes needed
   func canSave() throws -> Bool {
      if newTrackerName.isEmpty || newTrackerName == "" {
         throw EditTrackerError.emptyTrackerName
      }
      return true
   }
   
   func saveProperties() {
//      tm.tracker.name = newTrackerName
      moc.assertSave()
   }
   
   var body: some View {
      let _ = Self._printChanges()
      Background {
         VStack {
            List {
               Section {
                  VStack{
                     HStack {
                        Text("Name")
                           .fontWeight(.medium)
                        TextField("", text: $newTrackerName)
                           .multilineTextAlignment(.trailing)
                           .frame(height: 30)
                     }
                     ErrorLabel(message: "Tracker name can't be empty",
                                showError: $emptyTrackerNameError)
                  }
               }
               .listRowBackground(Color.cardColor)
               
               Section {
                  Button {
                     confirmDelete = true
                  } label: {
                     HStack {
                        Text("Delete Tracker")
                           .foregroundColor(.red)
                        Spacer()
                        Image(systemName: "trash")
                           .foregroundColor(.red)
                     }
                  }
                  .alert(
//                     "Are you sure you want to delete your tracker \"\(tm.tracker.name)\"?",
                     "test",
                     isPresented: $confirmDelete
                  ) {
                     Button("Delete", role: .destructive) {
//                        nav.path.removeLast()
                        isGoingToDelete = true
                     }
                     
                  }
               }
               .listRowBackground(Color.cardColor)
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
         }
      }
      .onDisappear {
         if !isGoingToDelete {
            do {
               if try canSave() {
                  saveProperties()
               }
            } catch {
               // empty tracker name, do not save
            }
         } else {
//            tm.delete(habit: vm.habit)
         }
      }
   }
}

struct EditTracker_Previews: PreviewProvider {
   
   static func data() -> (Habit, NumberTracker) {
      let context = CoreDataManager.previews.mainContext
      
      let day0 = Date()
      let day1 = Cal.date(byAdding: .day, value: -1, to: day0)!
      let day2 = Cal.date(byAdding: .day, value: -2, to: day0)!
      
      let h1 = try? Habit(context: context, name: "Swimming")
      h1?.markCompleted(on: day2)
      
      if let h1 = h1 {
         let t1 = NumberTracker(context: context, habit: h1, name: "Laps")
         t1.add(date: day0, value: "3")
         t1.add(date: day1, value: "2")
         t1.add(date: day2, value: "1")
      }
      
      let habits = Habit.habits(from: context)
      return (habits.first!, habits.first!.trackers.lastObject as! NumberTracker)
   }
   
   static var previews: some View {
      let t = data()
      NavigationView {
         EditTracker(tracker: t.1)
      }
   }
}
