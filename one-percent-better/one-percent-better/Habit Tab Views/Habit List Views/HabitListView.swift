//
//  HabitListView.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 5/8/22.
//

import SwiftUI
import CoreData

enum HabitListViewRoute: Hashable {
   case createHabit
   case showProgress(Habit)
}

class HabitListViewModel: NSObject, NSFetchedResultsControllerDelegate, ObservableObject {
   
   private let habitController: NSFetchedResultsController<Habit>
   private let moc: NSManagedObjectContext
   
   @Published var habitList: [UUID] = []
   
   init(_ context: NSManagedObjectContext) {
      let sortDescriptors = [NSSortDescriptor(keyPath: \Habit.orderIndex, ascending: true)]
      habitController = Habit.resultsController(context: context, sortDescriptors: sortDescriptors)
      moc = context
      super.init()
      habitController.delegate = self
      try? habitController.performFetch()
      
      habitList = habits.map { $0.id }
   }
   
   var habits: [Habit] {
      habitController.fetchedObjects ?? []
   }
   
   func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
      if habitList != habitUUIDs {
         habitList = habitUUIDs
      }
   }
   
   var habitUUIDs: [UUID] {
      return habits.map { $0.id }
   }
   
   func trackers(for habit: Habit) -> [Tracker] {
      habit.trackers.map { $0 as! Tracker }
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
}

struct HabitListView: View {
   
   @Environment(\.managedObjectContext) var moc
   @Environment(\.scenePhase) var scenePhase
   
   /// Navigation path model
   @EnvironmentObject var nav: HabitTabNavPath
   
   /// List of habits model
   @ObservedObject var vm: HabitListViewModel
   
   /// Habits header view model
   @ObservedObject var hwvm: HeaderWeekViewModel
   
   init(vm: HabitListViewModel) {
      self.vm = vm
      self.hwvm = HeaderWeekViewModel(hlvm: vm)
   }
   
   var body: some View {
      let _ = Self._printChanges()
      return (
         NavigationStack(path: $nav.path) {
            Background {
               VStack {
                  HabitsHeaderView()
                     .environmentObject(hwvm)
                  
                  if vm.habits.isEmpty {
                     NoHabitsView()
                     Spacer()
                  } else {
                     List {
                        ForEach(vm.habits, id: \.self.id) { habit in
                           if habit.started(before: hwvm.currentDay) {
                              
                              // Habit Row
                              NavigationLink(value: HabitListViewRoute.showProgress(habit)) {
                                 HabitRow(habit: habit, day: hwvm.currentDay)
                              }
                           }
                        }
                        .onMove(perform: vm.move)
                        .onDelete(perform: vm.delete)
                        
                        // Due today / not due today, need to create separate lists so not looping in view builder
                        //                     Section(header: Text("Not Due Today")) {
                        //                        ForEach(vm.habits, id: \.self.name) { habit in
                        //                           if habit.started(before: hwvm.currentDay),
                        //                              !habit.isDue(on: hwvm.currentDay) {
                        //                              NavigationLink(value: NavRoute.showProgress(habit)) {
                        //                                 HabitRow(habit: habit, day: hwvm.currentDay)
                        //                              }
                        //                           }
                        //                        }
                        //                        .onMove(perform: vm.move)
                        //                        .onDelete(perform: vm.delete)
                        //                     }
                     }
                     .environment(\.defaultMinListRowHeight, 54)
                  }
               }
            }
            .onAppear {
               hwvm.updateDayToToday()
            }
            .onChange(of: scenePhase, perform: { newPhase in
               if newPhase == .active {
                  hwvm.updateDayToToday()
               }
            })
            .toolbar {
               ToolbarItem(placement: .navigationBarLeading) {
                  EditButton()
               }
               ToolbarItem(placement: .navigationBarTrailing) {
                  NavigationLink(value: HabitListViewRoute.createHabit) {
                     Image(systemName: "square.and.pencil")
                  }
               }
            }
            .toolbarBackground(Color.backgroundColor, for: .tabBar)
            .navigationDestination(for: HabitListViewRoute.self) { route in
               if case let .showProgress(habit) = route {
                  ProgressView()
                     .environmentObject(habit)
               }
               
               if route == HabitListViewRoute.createHabit {
                  CreateNewHabit()
                     .environmentObject(vm)
               }
            }
            .navigationTitle(hwvm.navTitle)
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
