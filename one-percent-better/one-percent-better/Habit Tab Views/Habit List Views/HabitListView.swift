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

class HabitListViewModel: ConditionalManagedObjectFetcher<Habit>, Identifiable {
   
   @Published var habits: [Habit] = []
   
   /// A list of fetched habits by their IDs, used to not update the list view unless this array changes,
   /// i.e. only when a habit is added, removed, or moved
   var habitIDList: [UUID] = []
   
   init(_ context: NSManagedObjectContext = CoreDataManager.shared.mainContext) {
      super.init(context, sortDescriptors: [NSSortDescriptor(keyPath: \Habit.orderIndex, ascending: true)])
      habits = fetchedObjects
      habitIDList = habits.map { $0.id }
   }
   
   override func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
      let newHabits = controller.fetchedObjects as? [Habit] ?? []
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
      moc.assertSave()
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
      moc.assertSave()
   }
   
   /// A list of habits which are due today, on the selected day
   func habitsDueToday(on selectedDay: Date) -> [Habit] {
      return habits.compactMap { $0.isDue(on: selectedDay) ? $0 : nil }
   }
   
   /// A list of habits which are due this week, on the selected day
   func habitsDueThisWeek(on selectedDay: Date) -> [Habit] {
      return habits.compactMap { $0.isDue(on: selectedDay) ? nil : $0 }
   }
}

struct HabitListView: View {
   
   @Environment(\.managedObjectContext) var moc
   @Environment(\.editMode) var editMode
   
   @EnvironmentObject var hlvm: HabitListViewModel
   @EnvironmentObject var hsvm: HeaderSelectionViewModel
   
   enum HabitListSortOrder: String, CustomStringConvertible {
      case orderIndex
      case byWhenDue
      
      var description: String {
         switch self {
         case .orderIndex:
            return "Custom Order"
         case .byWhenDue:
            return "Sort by Due Date"
         }
      }
   }
   
   @State private var sortingSelection: [HabitListSortOrder] = [.byWhenDue]
   
   var body: some View {
      VStack {
         if hlvm.habits.isEmpty {
            NoHabitsView()
            Spacer()
         } else {
            List {
               if !sortingSelection.isEmpty {
                  let dueTodayHabits = hlvm.habitsDueToday(on: hsvm.selectedDay)
                  if !dueTodayHabits.isEmpty {
                     Section("Due Today") {
                        HabitListSectionView(habits: dueTodayHabits)
                     }
                  }
                  
                  let dueThisWeek = hlvm.habitsDueThisWeek(on: hsvm.selectedDay)
                  if !dueThisWeek.isEmpty {
                     Section("Due This Week") {
                        HabitListSectionView(habits: dueThisWeek)
                     }
                  }
               } else {
                  HabitListSectionView(habits: hlvm.habits)
               }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .environment(\.defaultMinListRowHeight, 54)
            .padding(.top, !sortingSelection.isEmpty ? 0 : -25)
            .clipShape(Rectangle())
            .animation(.easeInOut, value: sortingSelection)
         }
      }
      .toolbar {
         // Edit Habit List
         if !hlvm.habits.isEmpty {
            if editMode?.wrappedValue.isEditing == true {
               ToolbarItem(placement: .navigationBarLeading) {
                  EditButton()
               }
            } else {
               ToolbarItem(placement: .navigationBarLeading) {
                  Menu {
                     MenuItemWithCheckmarks(value: .byWhenDue, selections: $sortingSelection)
                     Divider()
                     EditButton()
                  } label: {
                     Image(systemName: "list.dash")
                  }
               }
            }
         }
      }
   }
}

struct HabitsViewPreviewer: View {
   
   static let h0id = UUID()
   static let h1id = UUID()
   static let h2id = UUID()
   static let h3id = UUID()
   static let h4id = UUID()
   static let h5id = UUID()
   
   @StateObject var nav = HabitTabNavPath()
   @StateObject var barManager = BottomBarManager()
   @StateObject var hlvm = HabitListViewModel(CoreDataManager.previews.mainContext)
   @StateObject var hsvm = HeaderSelectionViewModel(hwvm: HeaderWeekViewModel(CoreDataManager.previews.mainContext))
   
   init() {
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
      
      let h3 = try? Habit(context: context, name: "Due MWF", frequency: .specificWeekdays([.monday, .wednesday, .friday]), id: HabitsViewPreviewer.h3id)
      h3?.markCompleted(on: Date())
      
      let _ = try? Habit(context: context, name: "Due TTSS", frequency: .specificWeekdays([.tuesday, .thursday, .saturday, .sunday]), id: HabitsViewPreviewer.h4id)
      
      let _ = try? Habit(context: context, name: "Due 1x per week", frequency: .timesPerWeek(times: 1, resetDay: .sunday), id: HabitsViewPreviewer.h5id)
      
      context.assertSave()
   }
   
   var body: some View {
      NavigationStack(path: $nav.path) {
         HabitListView()
            .environmentObject(nav)
            .environmentObject(barManager)
            .environmentObject(hlvm)
            .environmentObject(hsvm)
      }
   }
}

struct HabitsView_Previews: PreviewProvider {
   static var previews: some View {
      Background {
         HabitsViewPreviewer()
            .environment(\.managedObjectContext, CoreDataManager.previews.mainContext)
      }
   }
}

struct NoHabitsView: View {
   
   @Environment(\.colorScheme) var scheme
   
   var body: some View {
      HStack(spacing: 0) {
         Text("To create a habit, press ")
            .foregroundColor(scheme == .light ? Color(hue: 1.0, saturation: 0.008, brightness: 0.279) : .secondaryLabel)
         NavigationLink(value: HabitListViewRoute.createHabit) {
            Image(systemName: "square.and.pencil")
         }
      }
      .padding(.top, 40)
   }
}

struct HabitListSectionView: View {
   
   @Environment(\.managedObjectContext) var moc
   
   @EnvironmentObject var hlvm: HabitListViewModel
   @EnvironmentObject var hsvm: HeaderSelectionViewModel
   
   var habits: [Habit]
   
   var body: some View {
      ForEach(habits, id: \.self.id) { habit in
         if habit.started(before: hsvm.selectedDay) {
            NavigationLink(value: HabitListViewRoute.showProgress(habit)) {
               HabitRow(moc: moc, habit: habit, day: hsvm.selectedDay)
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
