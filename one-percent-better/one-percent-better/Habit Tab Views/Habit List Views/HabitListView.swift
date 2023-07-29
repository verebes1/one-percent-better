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

/// The habit list view sections
enum HabitListSection: Int, CaseIterable, CustomStringConvertible {
    case dueToday
    case dueThisWeek
    
    var description: String {
        switch self {
        case .dueToday:
            return "Due Today"
        case .dueThisWeek:
            return "Due This Week"
        }
    }
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
    
    func sectionMove(from sourceIndex: IndexSet, to destination: Int, section: HabitListSection) {
        guard let source = sourceIndex.first else { fatalError("Bad index") }
        
        move(from: source, to: destination)
    }
    
    func move(from source: Int, to destination: Int) {
        // Make an array from fetched results
        var revisedItems: [Habit] = habits.map { $0 }
        
//        revisedItems.swapAt(source, destination)
        // Change the order of the items in the array
        let sourceIndex = IndexSet(integer: source)
        revisedItems.move(fromOffsets: sourceIndex, toOffset: destination)
        
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
    
    /// A subset of the list of habits based on the list section
    func habits(on selectedDay: Date, for section: HabitListSection) -> [Habit] {
        switch section {
        case .dueToday:
            return habits.filter { $0.isDue(on: selectedDay) }
        case .dueThisWeek:
            return habits.filter { !$0.isDue(on: selectedDay) }
        }
    }
}

struct HabitListView: View {
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.editMode) var editMode
    
    @EnvironmentObject var hlvm: HabitListViewModel
    @EnvironmentObject var hsvm: HeaderSelectionViewModel
    
    var body: some View {
        VStack {
            if hlvm.habits.isEmpty {
                NoHabitsListView()
                Spacer()
            } else {
                List {
                    ForEach(HabitListSection.allCases, id: \.self) { section in
                        HabitListSectionView(section: section)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .environment(\.defaultMinListRowHeight, 54)
                .padding(.top, -7)
                .clipShape(Rectangle())
            }
        }
        .toolbar {
            // Edit Habit List
            if !hlvm.habits.isEmpty {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
        }
    }
}


struct HabitListSectionView: View {
    
    @Environment(\.managedObjectContext) var moc
    
    @EnvironmentObject var hlvm: HabitListViewModel
    @EnvironmentObject var hsvm: HeaderSelectionViewModel
    
    /// Which section this list is
    let section: HabitListSection
    
    @State private var confirmDeleteHabit: Bool = false
    @State private var sourceDeleteIndex: IndexSet!
    
    var body: some View {
        let habits = hlvm.habits(on: hsvm.selectedDay, for: section)
        if !habits.isEmpty {
            Section(section.description) {
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
                .onMove { source, destination in
                    hlvm.sectionMove(from: source, to: destination, section: section)
                }
                .onDelete { source in
                    confirmDeleteHabit = true
                    sourceDeleteIndex = source
                }
            }
            .actionSheet(isPresented: $confirmDeleteHabit) {
                ActionSheet(
                    title: Text("Delete"),
                    message: Text("Are you sure you want to delete this habit?"),
                    buttons: [
                        .destructive(Text("Delete")) {
                            if let indexSet = sourceDeleteIndex {
                                hlvm.delete(from: indexSet)
                            }
                            sourceDeleteIndex = nil
                        },
                        .cancel {
                            sourceDeleteIndex = nil
                        }
                    ]
                )
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
