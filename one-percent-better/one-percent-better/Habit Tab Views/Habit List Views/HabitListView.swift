//
//  HabitListView.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 5/8/22.
//

import SwiftUI
import CoreData
import Combine

/// The navigation routes for the Habit List View
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
    
    /// A list of fetched habits by their frequencies, used to not update the list view unless this array changes,
    /// i.e. only when a habit frequency is changed and could shown in another section
    var habitFrequencies: [HabitFrequency?] = []
    
    var selectedDay = Date()
    var cancelBag = Set<AnyCancellable>()

    init(_ context: NSManagedObjectContext = CoreDataManager.shared.mainContext, hsvm: HeaderSelectionViewModel) {
        super.init(context, sortDescriptors: [NSSortDescriptor(keyPath: \Habit.orderIndex, ascending: true)])
        habits = fetchedObjects
        habitIDList = habits.map { $0.id }
        habitFrequencies = habits.map { $0.frequency(on: hsvm.selectedDay) }
        selectedDay = hsvm.selectedDay
        
        // Subscribe to selected day from HeaderSelectionViewModel
        hsvm.$selectedDay.sink { [weak self] newDate in
            guard let self else { return }
            self.selectedDay = newDate
            habitFrequencies = habits.map { $0.frequency(on: hsvm.selectedDay) }
        }
        .store(in: &cancelBag)
    }
    
    override func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let newHabits = controller.fetchedObjects as? [Habit] ?? []
        let newHabitIDList = newHabits.map { $0.id }
        let newHabitFrequencies = newHabits.map { $0.frequency(on: selectedDay) }
        
        if habitIDList != newHabitIDList {
            habits = newHabits
            habitIDList = newHabitIDList
            habitFrequencies = newHabitFrequencies
        } else if habitFrequencies != newHabitFrequencies {
            habits = newHabits
            habitFrequencies = newHabitFrequencies
        }
    }
    
    func move(from sourceIndex: IndexSet, to destination: Int) {
        // Make an array from fetched results
        var revisedItems: [Habit] = habits.map { $0 }
        
        // Change the order of the items in the array
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
        habitToBeDeleted.cleanUp()
        revisedItems.remove(atOffsets: source)
        moc.delete(habitToBeDeleted)
        for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1) {
            revisedItems[reverseIndex].orderIndex = Int(reverseIndex)
        }
        moc.assertSave()
    }
    
    /// A subset of the list of habits based on the list section
    func habits(on selectedDay: Date, for section: HabitListSection) -> [Habit] {
        let habits = habits.filter { $0.started(before: selectedDay) }
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
    
    @StateObject var hlvm: HabitListViewModel
    @EnvironmentObject var hsvm: HeaderSelectionViewModel
    
    @State private var editMode = EditMode.inactive
    
    @AppStorage("HabitListView.sortListByDue") private var sortListByDue = true
    
    init(moc: NSManagedObjectContext = CoreDataManager.shared.mainContext, hsvm: HeaderSelectionViewModel) {
        self._hlvm = StateObject(wrappedValue: HabitListViewModel(moc, hsvm: hsvm))
    }
    
    var body: some View {
        let _ = Self.printChanges(self)
        VStack {
            if hlvm.habits.isEmpty {
                NoHabitsListView()
                    .onAppear {
                        editMode = .inactive
                    }
                Spacer()
            } else {
                List {
                    switch editMode {
                    case .inactive, .transient:
                        if sortListByDue {
                            HabitListBySectionView()
                        } else {
                            HabitListByOrderIndexView()
                        }
                    case .active:
                        HabitListByOrderIndexView()
                    @unknown default:
                        Text("Unknown edit mode")
                            .onAppear { assertionFailure("Unknown edit mode") }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .environment(\.defaultMinListRowHeight, 54)
                .padding(.top, sortListByDue ? -7 : -25)
                .clipShape(Rectangle())
                .toolbar {
                    // Edit Habit List
                    ToolbarItem(placement: .navigationBarLeading) {
                        if case .inactive = editMode {
                            Menu {
                                MenuItemToggleCheckmark(value: "Sort by When Due", isSelected: $sortListByDue)
                                Divider()
                                EditButton()
                            } label: {
                                Image(systemName: "list.dash")
                            }
                        } else {
                            EditButton()
                        }
                    }
                }
                .environment(\.editMode, $editMode)
                .environmentObject(hlvm)
            }
        }
    }
}


struct HabitListBySectionView: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var hlvm: HabitListViewModel
    @EnvironmentObject var hsvm: HeaderSelectionViewModel
    
    var body: some View {
        ForEach(HabitListSection.allCases, id: \.self) { section in
            let habits = hlvm.habits(on: hsvm.selectedDay, for: section)
            if !habits.isEmpty {
                Section {
                    ForEach(habits, id: \.self.id) { habit in
                        NavigationLink(value: HabitListViewRoute.showProgress(habit)) {
                            HabitRow(moc: moc,
                                     habit: habit,
                                     hsvm: hsvm)
                        }
                        .listRowInsets(.init(top: 0,
                                             leading: 0,
                                             bottom: 0,
                                             trailing: 20))
                        .listRowBackground(Color.cardColor)
                    }
                } header: {
                    Text(section.description)
                } footer: {
                    HowToCompleteHabitTip()
                }
            }
        }
    }
}


struct HabitListByOrderIndexView: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var hlvm: HabitListViewModel
    @EnvironmentObject var hsvm: HeaderSelectionViewModel
    
    var body: some View {
        Section {
            ForEach(hlvm.habits, id: \.self.id) { habit in
                NavigationLink(value: HabitListViewRoute.showProgress(habit)) {
                    HabitRow(moc: moc,
                             habit: habit,
                             hsvm: hsvm)
                }
                .listRowInsets(.init(top: 0,
                                     leading: 0,
                                     bottom: 0,
                                     trailing: 20))
                .listRowBackground(Color.cardColor)
            }
            .onMove { source, dest in hlvm.move(from: source, to: dest) }
            .onDelete { source in hlvm.delete(from: source) }
        } footer: {
            HowToCompleteHabitTip()
        }
    }
}

//struct HabitListViewPreviewer: View {
//    
//    static let h0id = UUID()
//    static let h1id = UUID()
//    static let h2id = UUID()
//    static let h3id = UUID()
//    static let h4id = UUID()
//    static let h5id = UUID()
//    
//    @StateObject var nav = HabitTabNavPath()
//    @StateObject var barManager = BottomBarManager()
//    @StateObject var hlvm = HabitListViewModel(CoreDataManager.previews.mainContext)
//    @StateObject var hsvm = HeaderSelectionViewModel(hwvm: HeaderWeekViewModel(CoreDataManager.previews.mainContext))
//    
//    init() {
//        let _ = data()
//    }
//    
//    func data() {
//        let context = CoreDataManager.previews.mainContext
//        
//        let _ = try? Habit(context: context, name: "Never completed", id: HabitListViewPreviewer.h0id)
//        
//        let h1 = try? Habit(context: context, name: "Completed yesterday", id: HabitListViewPreviewer.h1id)
//        let yesterday = Cal.date(byAdding: .day, value: -1, to: Date())!
//        h1?.markCompleted(on: yesterday)
//        
//        let h2 = try? Habit(context: context, name: "Completed today", id: HabitListViewPreviewer.h2id)
//        h2?.markCompleted(on: Date())
//        
//        let h3 = try? Habit(context: context, name: "Due MWF", frequency: .specificWeekdays([.monday, .wednesday, .friday]), id: HabitListViewPreviewer.h3id)
//        h3?.markCompleted(on: Date())
//        
//        let _ = try? Habit(context: context, name: "Due TTSS", frequency: .specificWeekdays([.tuesday, .thursday, .saturday, .sunday]), id: HabitListViewPreviewer.h4id)
//        
//        let _ = try? Habit(context: context, name: "Due 1x per week", frequency: .timesPerWeek(times: 1, resetDay: .sunday), id: HabitListViewPreviewer.h5id)
//        
//        context.assertSave()
//    }
//    
//    var body: some View {
//        NavigationStack(path: $nav.path) {
//            HabitListView(moc: CoreDataManager.previews.mainContext)
//                .environmentObject(nav)
//                .environmentObject(barManager)
//                .environmentObject(hlvm)
//                .environmentObject(hsvm)
//        }
//    }
//}
//
//struct HabitListView_Previews: PreviewProvider {
//    static var previews: some View {
//        Background {
//            HabitListViewPreviewer()
//                .environment(\.managedObjectContext, CoreDataManager.previews.mainContext)
//        }
//    }
//}
