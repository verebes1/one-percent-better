//
//  HabitListView.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 5/8/22.
//

import SwiftUI
import CoreData
import Combine

enum HabitListViewRoute: Hashable {
   case createHabit
   case showProgress(Habit)
}

class HabitListViewModel: HabitConditionalFetcher {
   
   @Published var habits: [Habit] = []
   
   var habitIDList: [UUID] = []
   
   init(_ context: NSManagedObjectContext = CoreDataManager.shared.mainContext) {
      super.init(context)
      habits = habitController.fetchedObjects ?? []
      habitIDList = habits.map { $0.id }
   }
   
   override func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
      guard let newHabits = controller.fetchedObjects as? [Habit] else { return }
      let newHabitIDList = newHabits.map { $0.id }
      
      if habitIDList != newHabitIDList {
         habits = newHabits
         habitIDList = newHabitIDList
      }
   }
   
   func move(from source: IndexSet, to destination: Int) {
      // Make an array from fetched results
      var revisedItems: [Habit] = habits.map { $0 }
      
      // Change the order of the items in the array
      revisedItems.move(fromOffsets: source, toOffset: destination)
      
      // Update the orderIndex indices
      for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1) {
         revisedItems[reverseIndex].orderIndex = Int(reverseIndex)
      }
      moc.perform {
         self.moc.assertSave()
      }
   }
   
   func delete(from source: IndexSet) {
      // Make an array from fetched results
      var revisedItems: [Habit] = habits.map { $0 }
      
      // Remove the item to be deleted
      guard let index = source.first else { return }
      let habitToBeDeleted = revisedItems[index]
      revisedItems.remove(atOffsets: source)
      moc.delete(habitToBeDeleted)
      
      for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1) {
         revisedItems[reverseIndex].orderIndex = Int(reverseIndex)
      }
      moc.perform {
         self.moc.assertSave()
      }
   }
}

struct HabitListView: View {
   
   @Environment(\.managedObjectContext) var moc
   @EnvironmentObject var nav: HabitTabNavPath
   @EnvironmentObject var hlvm: HabitListViewModel
   @EnvironmentObject var selectedDayModel: SelectedDayModel
   
   let habits: [Habit]
   
   @State private var hideTabBar = false
   
   var body: some View {
      let _ = Self._printChanges()
      VStack {
         if habits.isEmpty {
            NoHabitsView()
            Spacer()
         } else {
            List {
               Section {
                  ForEach(habits, id: \.self.id) { habit in
                     if habit.started(before: selectedDayModel.selectedDay) {
                        // Habit Row
                        NavigationLink(value: HabitListViewRoute.showProgress(habit)) {
                           HabitRow(habit: habit, day: selectedDayModel.selectedDay)
                        }
                        .listRowInsets(.init(top: 0,
                                             leading: 0,
                                             bottom: 0,
                                             trailing: 20))
                        .listRowBackground(Color.cardColor)
                     }
                  }
                  .onMove(perform: hlvm.move)
                  .onDelete(perform: hlvm.delete)
               }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .environment(\.defaultMinListRowHeight, 54)
            .padding(.top, -25)
            .clipShape(Rectangle())
         }
      }
      
      .toolbar {
         // Edit
         ToolbarItem(placement: .navigationBarLeading) {
            EditButton()
         }
         // New Habit
         ToolbarItem(placement: .navigationBarTrailing) {
            NavigationLink(value: HabitListViewRoute.createHabit) {
               Image(systemName: "square.and.pencil")
            }
         }
      }
      .toolbarBackground(Color.backgroundColor, for: .tabBar)
      .navigationDestination(for: HabitListViewRoute.self) { route in
         if case let .showProgress(habit) = route {
            HabitProgessView()
               .environmentObject(nav)
               .environmentObject(habit)
         }
         
         if case .createHabit = route {
            CreateHabitName(hideTabBar: $hideTabBar)
               .environmentObject(nav)
         }
      }
      .navigationTitle(selectedDayModel.navTitle)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar(hideTabBar ? .hidden : .visible, for: .tabBar)
      
   }
}

struct HabitsViewPreviewer: View {
   
   @Environment(\.managedObjectContext) var moc
   
   static let h0id = UUID()
   static let h1id = UUID()
   static let h2id = UUID()
   
   @StateObject var nav = HabitTabNavPath()
   @StateObject var habitList_VM: HabitListViewModel
   @StateObject var headerWeek_VM: HeaderWeekViewModel
   
   init() {
      let hlvm = HabitListViewModel(CoreDataManager.previews.mainContext)
      let hwvm = HeaderWeekViewModel(CoreDataManager.previews.mainContext)
      _habitList_VM = StateObject(wrappedValue: hlvm)
      _headerWeek_VM = StateObject(wrappedValue: hwvm)
      let _ = data()
   }
   
   func data() {
      let context = CoreDataManager.previews.mainContext
      
      let _ = try? Habit(context: context, name: "Never completed", id: HabitsViewPreviewer.h0id)
      
      let h1 = try? Habit(context: context, name: "Completed yesterday", id: HabitsViewPreviewer.h1id)
      let yesterday = Cal.date(byAdding: .day, value: -1, to: Date())!
      h1?.markCompleted(on: yesterday)
      
      let h2 = try? Habit(context: context, name: "Completed today", id: HabitsViewPreviewer.h2id)
      h2?.markCompleted(on: Date())
   }
   
   var body: some View {
      NavigationStack(path: $nav.path) {
         HabitListView(habits: habitList_VM.habits)
            .environmentObject(headerWeek_VM)
            .environment(\.managedObjectContext, moc)
            .environmentObject(nav)
      }
   }
}

struct HabitsView_Previews: PreviewProvider {
   static var previews: some View {
      HabitsViewPreviewer()
   }
}

struct NoHabitsView: View {
   
   @Environment(\.colorScheme) var scheme
   
   var body: some View {
      HStack(spacing: 0) {
         Text("To create a habit, press ")
         Image(systemName: "square.and.pencil")
      }
      .foregroundColor(scheme == .light ? Color(hue: 1.0, saturation: 0.008, brightness: 0.279) : .secondaryLabel)
      .padding(.top, 40)
   }
}
