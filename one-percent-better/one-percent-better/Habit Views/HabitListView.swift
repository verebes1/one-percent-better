//
//  HabitListView.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 5/8/22.
//

import SwiftUI
import CoreData

class HabitListViewModel: NSObject, NSFetchedResultsControllerDelegate, ObservableObject {
    
    private let habitController: NSFetchedResultsController<Habit>
    private let moc: NSManagedObjectContext
    
    /// The current selected day
    @Published var currentDay: Date = Date()
    
    /// The latest day that has been shown. This is updated when the
    /// app is opened or the view appears on a new day.
    @Published var latestDay: Date = Date()
    
    @Published var selectedWeekDay: Int = 0
    @Published var selectedWeek: Int = 0
    
    init(_ context: NSManagedObjectContext) {
        let sortDescriptors = [NSSortDescriptor(keyPath: \Habit.orderIndex, ascending: true)]
        habitController = Habit.resultsController(context: context, sortDescriptors: sortDescriptors)
        moc = context
        super.init()
        habitController.delegate = self
        try? habitController.performFetch()
        
        selectedWeekDay = thisWeekDayOffset(currentDay)
        selectedWeek = getSelectedWeek(for: currentDay)
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        objectWillChange.send()
    }
    
    var habits: [Habit] {
        return habitController.fetchedObjects ?? []
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
//        habitToBeDeleted.de
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
    
    func navTitle(for date: Date) -> String {
        dateTitleFormatter.string(from: date)
    }
    
    /// Date of the earliest start date for all habits
    var earliestStartDate: Date {
        var earliest = Date()
        for habit in habits {
            if habit.startDate < earliest {
                earliest = habit.startDate
            }
        }
        return earliest
    }
    
    /// Number of weeks (each row is a week) between today and the earliest completed habit
    var numWeeksSinceEarliest: Int {
        let numDays = Calendar.current.dateComponents([.day], from: earliestStartDate, to: Date()).day!
        let diff = numDays - thisWeekDayOffset(Date()) + 6
        let weeks = diff / 7
        return weeks + 1
    }
    
    /// The number of days to offset from today to get to the selected day
    /// - Parameters:
    ///   - week: Selected week, (numWeeksSinceEarliest - 1) == current week, 0 == earliest week
    ///   - day: Selected day,  [0,1,2,3,4,5,6]
    /// - Returns: Integer offset, yesterday is -1, today is 0, tomorrow is 1, etc.
    func dayOffset(week: Int, day: Int) -> Int {
        let numDaysBack = day - thisWeekDayOffset(Date())
        let numWeeksBack = week - (numWeeksSinceEarliest - 1)
        if numWeeksBack == 0 {
            return numDaysBack
        } else {
            return (numWeeksBack * 7) + numDaysBack
        }
    }
    
    func dayOffsetToToday(from date: Date) -> Int {
        let result = -(Calendar.current.numberOfDaysBetween(date, and: Date()) - 1)
        return result
    }
    
    func getSelectedWeek(for day: Date) -> Int {
        let weekDayOffset = thisWeekDayOffset(day)
        let totalDayOffset = -(Calendar.current.numberOfDaysBetween(day, and: Date()) - 1)
        let weekNum = (weekDayOffset - totalDayOffset - 1) / 7
        let result = numWeeksSinceEarliest - 1 - weekNum
        return result
    }
    
    func dayOffsetFromEarliest(week: Int, day: Int) -> Int {
        let numDaysBack = day - thisWeekDayOffset(earliestStartDate)
        let numWeeksBack = week
        if numWeeksBack == 0 {
            return numDaysBack
        } else {
            return (numWeeksBack * 7) + numDaysBack
        }
    }
    
    func date(week: Int, day: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: dayOffset(week: week, day: day), to: Date())!
    }
    
    func percent(week: Int, day: Int) -> Double {
        let day = date(week: week, day: day)
        var numCompleted: Double = 0
        var total: Double = 0
        for habit in habits {
            if Calendar.current.startOfDay(for: habit.startDate) <= Calendar.current.startOfDay(for: day) {
                total += 1
            }
        }
        guard total > 0 else { return 0 }
        
        for habit in habits {
            if habit.wasCompleted(on: day) {
                numCompleted += 1
            }
            
        }
        return numCompleted / total
    }
    
    func thisWeekDayOffset(_ date: Date) -> Int {
        return Calendar.current.component(.weekday, from: date) - 1
    }
}

struct HabitListView: View {
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.scenePhase) var scenePhase
    
    @ObservedObject var vm: HabitListViewModel
    
    @State var createHabitPresenting: Bool = false
    
    var body: some View {
        NavigationView {
            Background {
                VStack {
                    HabitsHeaderView()
                        .environmentObject(vm)
                    
                    List {
                        ForEach(vm.habits, id: \.self.name) { habit in
                            if habit.started(after: vm.currentDay) {
                                let progressVM = ProgressViewModel(habit: habit)
                                let dest = ProgressView(vm: progressVM).environmentObject(habit)
                                let habitRowVM = HabitRowViewModel(habit: habit,
                                                                   currentDay:
                                                                    vm.currentDay)
                                NavigationLink(destination: dest) {
                                    HabitRow(vm: habitRowVM)
                                }
                                .isDetailLink(false)
                            }
                        }
                        .onMove(perform: vm.move)
                        .onDelete(perform: vm.delete)
                    }
                    .environment(\.defaultMinListRowHeight, 54)
                }
            }
            .onAppear {
                UITableView.appearance().contentInset.top = -25
                
                if !Calendar.current.isDate(vm.latestDay, inSameDayAs: Date()) {
                    vm.latestDay = Date()
                    vm.currentDay = Date()
                }
            }
            .onChange(of: scenePhase, perform: { newPhase in
                if newPhase == .active, !Calendar.current.isDate(vm.latestDay, inSameDayAs: Date()) {
                    vm.latestDay = Date()
                    vm.currentDay = Date()
                }
            })
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(
                        destination: CreateNewHabit(rootPresenting: $createHabitPresenting),
                        isActive: $createHabitPresenting) {
                            Image(systemName: "square.and.pencil")
                        }
                }
            }
            .navigationTitle(vm.navTitle(for: vm.currentDay))
            .navigationBarTitleDisplayMode(.inline)
            
        }
    }
}

struct HabitsView_Previews: PreviewProvider {
    
    static var previews: some View {
        PreviewData.habitViewData()
        let moc = CoreDataManager.previews.persistentContainer.viewContext
        return HabitListView(vm: HabitListViewModel(moc))
            .environment(\.managedObjectContext, moc)
    }
}
