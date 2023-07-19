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
}

struct HabitListView: View {
   
   @Environment(\.managedObjectContext) var moc
   @Environment(\.editMode) var editMode
   
   @EnvironmentObject var hlvm: HabitListViewModel
   @EnvironmentObject var hsvm: HeaderSelectionViewModel
   
   @State private var sortingSelection = "Ordered"
   
   var body: some View {
      let _ = Self._printChanges()
      VStack {
         Text("editMode: \(String(describing: editMode?.wrappedValue.isEditing))")
         if hlvm.habits.isEmpty {
            NoHabitsView()
            Spacer()
         } else {
            List {
               Section {
                  ForEach(hlvm.habits, id: \.self.id) { habit in
                     if habit.started(before: hsvm.selectedDay) {
                        NavigationLink(value: HabitListViewRoute.showProgress(habit)) {
                           HabitRow(habit: habit, day: hsvm.selectedDay)
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
         // Edit Habit List
         if !hlvm.habits.isEmpty {
            if editMode?.wrappedValue.isEditing == true {
               ToolbarItem(placement: .navigationBarLeading) {
                  EditButton()
               }
            } else {
               ToolbarItem(placement: .navigationBarLeading) {
                  Menu {
                     Menu {
                        MenuItemWithCheckmark(value: "Custom Order", selection: $sortingSelection)
                        MenuItemWithCheckmark(value: "Due / Not Due", selection: $sortingSelection)
                     } label: {
                        Label("Sort by", systemImage: "tray")
                     }
                     
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
