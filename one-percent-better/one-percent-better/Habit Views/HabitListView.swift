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
    
    init(_ context: NSManagedObjectContext) {
        let sortDescriptors = [NSSortDescriptor(keyPath: \Habit.orderIndex, ascending: true)]
        habitController = Habit.resultsController(context: context, sortDescriptors: sortDescriptors)
        moc = context
        super.init()
        habitController.delegate = self
        try? habitController.performFetch()
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
}

struct HabitListView: View {
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.scenePhase) var scenePhase
    
    @ObservedObject var vm: HabitListViewModel
    
    /// The current selected day
    @State private var currentDay: Date = Date()
    
    /// The latest day that has been shown. This is updated when the app is opened or the view appears on a new day.
    @State private var latestDay: Date = Date()
    
    @State var createHabitPresenting: Bool = false
    
    var body: some View {
        NavigationView {
            Background {
                VStack {
                    let headerVM = HabitsHeaderViewModel(habits: vm.habits)
                    HabitsHeaderView(vm: headerVM,
                                     currentDay: $currentDay)
                    
                    List {
                        ForEach(vm.habits, id: \.self.name) { habit in
                            if Calendar.current.startOfDay(for: habit.startDate) <= Calendar.current.startOfDay(for: currentDay) {
                                let progressVM = ProgressViewModel(habit: habit)
                                NavigationLink(
                                    destination: ProgressView(vm: progressVM).environmentObject(habit)) {
                                        HabitRow(vm: HabitRowViewModel(habit: habit,
                                                                       currentDay:
                                                                        currentDay))
                                            .environmentObject(habit)
                                            .animation(.easeInOut, value: currentDay)
                                    }
                                    .isDetailLink(false)
                            }
                        }
                        .onMove(perform: vm.move)
                        .onDelete(perform: vm.delete)
                    }
                }
            }
            .onAppear {
                UITableView.appearance().contentInset.top = -25
                
                if !Calendar.current.isDate(latestDay, inSameDayAs: Date()) {
                    latestDay = Date()
                    currentDay = Date()
                }
            }
            .onChange(of: scenePhase, perform: { newPhase in
                if newPhase == .active, !Calendar.current.isDate(latestDay, inSameDayAs: Date()) {
                    latestDay = Date()
                    currentDay = Date()
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
            .navigationTitle(vm.navTitle(for: currentDay))
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

class HabitRowViewModel: ObservableObject {
    let habit: Habit
    let currentDay: Date
    
    init(habit: Habit, currentDay: Date) {
        self.habit = habit
        self.currentDay = currentDay
    }
    
    /// Current streak (streak = 1 if completed today, streak = 2 if completed today and yesterday, etc.)
    var streak: Int {
        get {
            var streak = 0
            // start at yesterday, a streak is only broken if it's not completed by the end of the day
            var day = Calendar.current.date(byAdding: .day, value: -1, to: currentDay)!
            while habit.wasCompleted(on: day) {
                streak += 1
                day = Calendar.current.date(byAdding: .day, value: -1, to: day)!
            }
            // add 1 if completed today
            if habit.wasCompleted(on: currentDay) {
                streak += 1
            }
            return streak
        }
    }
    
    var notDoneIn: Int {
        var difference = 0
        var day = Calendar.current.startOfDay(for: currentDay)
        day = Calendar.current.date(byAdding: .day, value: -1, to: day)!
        if day > habit.startDate {
            while !habit.wasCompleted(on: day) {
                difference += 1
                day = Calendar.current.date(byAdding: .day, value: -1, to: day)!
                if day < habit.startDate {
                    break
                }
            }
            return difference
        } else {
            return -1
        }
    }

    /// Streak label used in habit view
    var streakLabel: String {
        if streak > 0 {
            return "\(streak) day streak"
        } else if habit.daysCompleted.isEmpty || notDoneIn == -1 {
            return "Never done"
        } else {
            let diff = notDoneIn
            let dayText = diff == 1 ? "day" : "days"
            return "Not done in \(diff) \(dayText)"
        }
    }

    /// Color of streak label used in habit view
    var streakLabelColor: Color {
        if streak > 0 {
            return .green
        } else if habit.daysCompleted.isEmpty || notDoneIn == -1 {
            return Color(hue: 1.0, saturation: 0.0, brightness: 0.519)
        } else {
            return .red
        }
    }
}

struct HabitRow: View {
    
    @ObservedObject var vm: HabitRowViewModel
    
    var body: some View {
        HStack {
            VStack {
                HabitCompletionCircle(currentDay: vm.currentDay,
                                      size: 28,
                                      startValue: vm.habit.wasCompleted(on: vm.currentDay))
            }
            VStack(alignment: .leading) {
                
                Text(vm.habit.name)
                    .font(.system(size: 16))
                
                Text(vm.streakLabel)
                    .font(.system(size: 11))
                    .foregroundColor(vm.streakLabelColor)
            }
            Spacer()
        }
    }
}
