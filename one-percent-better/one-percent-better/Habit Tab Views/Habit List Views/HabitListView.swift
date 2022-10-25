//
//  HabitListView.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 5/8/22.
//

import SwiftUI
import CoreData
import Combine

class HabitListViewModel: NSObject, NSFetchedResultsControllerDelegate, ObservableObject {
   
   private let habitController: NSFetchedResultsController<Habit>
   private let moc: NSManagedObjectContext
   
   /// The current selected day
   @Published var currentDay: Date = Date()
   
   /// The latest day that has been shown. This is updated when the
   /// app is opened or the view appears on a new day.
   @Published var latestDay: Date = Date()
   
   init(_ context: NSManagedObjectContext) {
      let sortDescriptors = [NSSortDescriptor(keyPath: \Habit.orderIndex, ascending: true)]
      habitController = Habit.resultsController(context: context, sortDescriptors: sortDescriptors)
      moc = context
      super.init()
      habitController.delegate = self
      try? habitController.performFetch()
      
      updateHeaderView()
   }
   
   func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
      let newObjects = controller.fetchedObjects
      print("Habits changing\n-------------------------")
      objectWillChange.send()
   }
   
   var habits: [Habit] {
      return habitController.fetchedObjects ?? []
   }
   
   func trackers(for habit: Habit) -> [Tracker] {
      habit.trackers.map { $0 as! Tracker }
   }
   
//   func updateHeaderView() {
//      selectedWeekDay = thisWeekDayOffset(currentDay)
//      selectedWeek = getSelectedWeek(for: currentDay)
//   }
   
   func updateDayToToday() {
      if !Calendar.current.isDate(latestDay, inSameDayAs: Date()) {
         latestDay = Date()
         currentDay = Date()
      }
//      updateHeaderView()
   }
   
   func move(from source: IndexSet, to destination: Int) {
      // Make an array from fetched results
      var revisedItems: [Habit] = habits.map { $0 }
      
      // Change the order of the items in the array
      revisedItems.move(fromOffsets: source, toOffset: destination)
      
      // Update the orderIndex indices
      for reverseIndex in stride(from: revisedItems.count - 1,
                                 through: 0,
                                 by: -1) {
         revisedItems[reverseIndex].orderIndex = Int(reverseIndex)
      }
      moc.fatalSave()
   }
   
   func delete(from source: IndexSet) {
      // Make an array from fetched results
      var revisedItems: [Habit] = habits.map{ $0 }
      
      // Remove the item to be deleted
      guard let index = source.first else { return }
      let habitToBeDeleted = revisedItems[index]
      revisedItems.remove(atOffsets: source)
      moc.delete(habitToBeDeleted)
      
      for reverseIndex in stride(from: revisedItems.count - 1,
                                 through: 0,
                                 by: -1) {
         revisedItems[reverseIndex].orderIndex = Int(reverseIndex)
      }
      moc.fatalSave()
   }
   
   /// Date formatter for the month year label at the top of the calendar
   var dateTitleFormatter: DateFormatter = {
      let dateFormatter = DateFormatter()
      dateFormatter.calendar = Calendar(identifier: .gregorian)
      dateFormatter.locale = Locale.autoupdatingCurrent
      dateFormatter.setLocalizedDateFormatFromTemplate("EEEE, MMM d, YYYY")
      return dateFormatter
   }()
   
   var navTitle: String {
      dateTitleFormatter.string(from: currentDay)
   }
}


class HabitsOnlyListModel: ObservableObject {
   var cancellable: [AnyCancellable?] = []
   
   @Published var habitIDs: [UUID] = []
   @Published var currentDay: Date = Date()
   
   init() {
      cancellable.append( HabitsGlobalModel.shared.objectWillChange.sink { [weak self] newGM in
         guard let strongSelf = self else { fatalError("Unable to get self") }
         let newList = HabitsGlobalModel.shared.habits.compactMap { habit in
            if habit.started(before: strongSelf.currentDay) {
               return habit.id
            }
            return nil
         }
         if strongSelf.habitIDs != newList {
            print("UPDATING LIST!!")
            strongSelf.habitIDs = newList
         }
      })
      
      cancellable.append( HabitsGlobalModel.shared.$currentDay.sink { newDay in
         self.currentDay = newDay
         print("New day!")
      })
      
      habitIDs = HabitsGlobalModel.shared.habits.map { $0.id }
   }
   
   func habit(for uuid: UUID) -> Habit {
      HabitsGlobalModel.shared.habits.first { $0.id == uuid }!
   }
}


struct HabitListView: View {
   
   @Environment(\.managedObjectContext) var moc
   @Environment(\.scenePhase) var scenePhase
   
   @EnvironmentObject var nav: HabitTabNavPath
   
   @ObservedObject var vm: HabitListViewModel
   
   /// If CreateNewHabit is being presented
   @State private var createHabitPresenting: Bool = false
   
   /// The habit of the row which was selected
   @State private var selectedHabit: Habit?
   
   @StateObject var newVM = HabitsOnlyListModel()
   
   var body: some View {
      
      print("Reloading LIST")
      return (
      NavigationStack(path: $nav.path) {
         Background {
            VStack {
               HabitsHeaderView(selectedWeek: vm.selectedWeek)
                  .environmentObject(vm)
               
               if vm.habits.isEmpty {
                  NoHabitsView()
                  Spacer()
               } else {
//                  List {
//                     ForEach(vm.habits, id: \.self.name) { habit in
//                        if habit.started(before: vm.currentDay) {
//                           NavigationLink(value: NavRoute.showProgress(habit)) {
//                              HabitRow(habit: habit, day: vm.currentDay)
//                           }
//                        }
//                     }
                  // TODO: REDO MOVE AND DELETE TO USE UUID
//                     .onMove(perform: vm.move)
//                     .onDelete(perform: vm.delete)
//                  }
//                  .environment(\.defaultMinListRowHeight, 54)
                  List {
                     ForEach(newVM.habitIDs, id: \.self) { habitID in
                        NavigationLink(value: NavRoute.showProgress(habitID)) {
                           HabitRow(habit: newVM.habit(for: habitID), day: newVM.currentDay)
                        }
                     }
//                     .onMove(perform: vm.move)
//                     .onDelete(perform: vm.delete)
                  }
                  .environment(\.defaultMinListRowHeight, 54)
               }
               
               
            }
         }
         // TODO: PUT BACK AFTER FIXING LIST RELOAD
//         .onAppear {
//            vm.updateDayToToday()
//         }
//         .onChange(of: scenePhase, perform: { newPhase in
//            if newPhase == .active {
//               vm.updateDayToToday()
//            }
//         })
         .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
               EditButton()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
               NavigationLink(value: NavRoute.createHabit) {
                  Image(systemName: "square.and.pencil")
               }
            }
         }
         .navigationDestination(for: NavRoute.self) { route in
            if case let .showProgress(habitID) = route {
               ProgressView()
                  .environmentObject(newVM.habit(for: habitID))
            }
            
            if route == NavRoute.createHabit {
               CreateNewHabit()
                  .environmentObject(vm)
            }
         }
         .navigationTitle(vm.navTitle)
         .navigationBarTitleDisplayMode(.inline)
         .navigationViewStyle(StackNavigationViewStyle())
      }
      )
   }
}

struct HabitsView_Previews: PreviewProvider {
   
   static func data() {
      let context = CoreDataManager.previews.mainContext
      
      let _ = try? Habit(context: context, name: "Never completed")

      let h1 = try? Habit(context: context, name: "Completed yesterday")
      let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
      h1?.markCompleted(on: yesterday)

      let h2 = try? Habit(context: context, name: "Completed today")
      h2?.markCompleted(on: Date())
   }
   
   static var previews: some View {
      let moc = CoreDataManager.previews.mainContext
      let _ = data()
      HabitListView(vm: HabitListViewModel(moc))
         .environment(\.managedObjectContext, moc)
         .environmentObject(HabitTabNavPath())
   }
}

struct NoHabitsView: View {
   
   @Environment(\.colorScheme) var scheme
   
   var body: some View {
      HStack {
         Text("To create a habit, press")
         Image(systemName: "square.and.pencil")
      }
      .foregroundColor(scheme == .light ? Color(hue: 1.0, saturation: 0.008, brightness: 0.279) : .secondaryLabel)
      .padding(.top, 40)
   }
}
