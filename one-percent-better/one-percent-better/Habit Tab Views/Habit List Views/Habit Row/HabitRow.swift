//
//  HabitRow.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 7/29/22.
//

import SwiftUI
import Combine
import CoreData

struct StreakLabel: Equatable {
    let label: String
    let color: Color
    
    static let gray = Color(hue: 1.0, saturation: 0.0, brightness: 0.519)
    
    init(_ label: String, _ color: Color) {
        self.label = label
        self.color = color
    }
}

class HabitRowViewModel: ConditionalManagedObjectFetcher<Habit> {
    
    @Published var habit: Habit
    @Published var timerLabel: String = "00:00"
    @Published var isTimerRunning: Bool
    
    @Published var currentDay: Date
    var cancelBag = Set<AnyCancellable>()
    
    var hasTimeTracker: Bool
    var hasTimerStarted: Bool
    
    init(moc: NSManagedObjectContext = CoreDataManager.shared.mainContext, habit: Habit, sdvm: SelectedDateViewModel) {
//        print("init HabitRowViewModel \(habit.name)")
        self.habit = habit
        self.currentDay = sdvm.selectedDate
        isTimerRunning = false
        hasTimeTracker = false
        hasTimerStarted = false
        super.init(moc, predicate: NSPredicate(format: "id == %@", habit.id as CVarArg))
        
        // Subscribe to selected day from SelectedDateViewModel
        sdvm.$selectedDate.sink { newDate in
            self.currentDay = newDate
        }
        .store(in: &cancelBag)
        
        // Time Tracker
        /*
         if let t = self.habit.timeTracker {
         t.callback = updateTimerString(to:)
         isTimerRunning = t.isRunning
         hasTimeTracker = true
         if let value = t.getValue(on: self.currentDay) {
         self.updateTimerString(to: value)
         if value != 0 {
         hasTimerStarted = true
         }
         }
         }
         */
    }
    
    override func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let newHabits = controller.fetchedObjects as? [Habit] ?? []
        guard !newHabits.isEmpty else { return }
        assert(newHabits.count == 1, "two habits with same id: \(newHabits)")
        habit = newHabits.first!
    }
    
    func streakLabel(on day: Date) -> StreakLabel? {
        // Do not calculate streak if never completed up to this point
        guard let firstCompleted = habit.daysCompleted.first,
              firstCompleted.startOfDay <= day.startOfDay  else {
            return StreakLabel("No streak", StreakLabel.gray)
        }
        
        guard let freq = habit.frequency(on: day) else { return nil }
        let streak = habit.streak(on: day)
        if streak > 0 {
            var timePeriodText: String
            switch freq {
            case .timesPerDay, .specificWeekdays:
                timePeriodText = "day"
            case .timesPerWeek:
                timePeriodText = "week"
            }
            return StreakLabel("\(streak) \(timePeriodText) streak", .green)
        } else if let days = habit.notDoneInDays(on: day),
                  days > 0 {
            switch freq {
            case .timesPerDay:
                let dayText = days == 1 ? "day" : "days"
                return StreakLabel("Not done in \(days) \(dayText)", .red)
            case .specificWeekdays, .timesPerWeek:
                assert(days >= 8)
                let weeks = days / 7
                let weekText = weeks == 1 ? "week" : "weeks"
                return StreakLabel("Not done in \(weeks) \(weekText)", .red)
            }
        } else {
            return StreakLabel("No streak", StreakLabel.gray)
        }
    }
    
    var timesCompleted: Int {
        switch habit.frequency(on: currentDay) {
        case .timesPerDay:
            return habit.timesCompleted(on: currentDay)
        case .specificWeekdays, .timesPerWeek:
            return habit.timesCompletedThisWeek(on: currentDay, upTo: true)
        case .none:
            return 0
        }
    }
    
    var timesExpected: Int {
        switch habit.frequency(on: currentDay) {
        case .timesPerDay(let tpd):
            return tpd
        case .specificWeekdays(let weekdays):
            return weekdays.count
        case .timesPerWeek(times: let tpw, _):
            return tpw
        case .none:
            return 0
        }
    }
    
    var shouldShowTimesCompletedIndicator: Bool {
        switch habit.frequency(on: currentDay) {
        case .timesPerDay(let tpd):
            return tpd > 1
        case .specificWeekdays, .timesPerWeek:
            return true
        case .none:
            return false
        }
    }
    
    // Timer
    /*
     func getTimerString(from time: Int) -> String {
     var seconds = "\(time % 60)"
     if time % 60 < 10 {
     seconds = "0" + seconds
     }
     var minutes = "\((time / 60) % 60)"
     if (time / 60) % 60 < 10 {
     minutes = "0" + minutes
     }
     return minutes + ":" + seconds
     }
     
     func updateTimerString(to value: Int) {
     self.timerLabel = getTimerString(from: value)
     
     if let t = habit.timeTracker {
     if value >= t.goalTime {
     habit.markCompleted(on: currentDay)
     }
     }
     }
     
     var timePercentComplete: Double {
     guard let t = habit.timeTracker else {
     return 0
     }
     guard let soFar = t.getValue(on: currentDay) else {
     return 0
     }
     return Double(soFar) / Double(t.goalTime)
     }
     */
}

struct HabitRow: View {
    
    @Environment(\.editMode) private var editMode
    
    @StateObject var vm: HabitRowViewModel
    @State private var completePressed = false
    
    init(moc: NSManagedObjectContext = CoreDataManager.shared.mainContext, habit: Habit, sdvm: SelectedDateViewModel) {
        self._vm = StateObject(wrappedValue: HabitRowViewModel(moc: moc, habit: habit, sdvm: sdvm))
    }
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                Spacer().frame(width: 15)
                
                HabitCompletionCircle(size: 28,
                                      completedPressed: $completePressed)
                
                Spacer().frame(width: 15)
                
                HabitRowLabels()
                
                Spacer()
                
                if editMode?.wrappedValue.isEditing == false {
                    ImprovementGraphView()
                        .frame(width: 80, height: 35)
                        .padding(.trailing, 10)
                        .animation(.easeInOut, value: editMode?.wrappedValue)
                }
                
            }
            .environmentObject(vm)
            .listRowBackground(vm.isTimerRunning ? Color.green.opacity(0.1) : Color.white)
            
            // Left side of habit row is completion button
            // TODO: 1.1.5 Try this with Rectangle() instead of path? Might fix errant clicks on row
            GeometryReader { geo in
                Color.clear
                    .contentShape(Path(CGRect(origin: .zero, size: CGSize(width: geo.size.width / 3, height: geo.size.height))))
                    .onTapGesture {
                        completePressed.toggle()
                    }
            }
        }
    }
}

struct HabitRowPreviewer: View {

    @ObservedObject var vm: HabitListViewModel

    @State private var currentDay = Date()

    @StateObject var nav = HabitTabNavPath()
    @StateObject var sdvm = SelectedDateViewModel()

    var body: some View {
        NavigationStack {
            Background {
                List {
                    ForEach(vm.habits) { habit in
                        HabitRow(moc: CoreDataManager.previews.mainContext,
                                 habit: habit,
                                 sdvm: sdvm)
                        .listRowInsets(.init(top: 0,
                                             leading: 0,
                                             bottom: 0,
                                             trailing: 20))
                    }
                }
                .environment(\.defaultMinListRowHeight, 54)
            }
            .environmentObject(nav)
        }
    }
}

//struct HabitRow_Previews: PreviewProvider {
//
//    static let id1 = UUID()
//    static let id2 = UUID()
//    static let id3 = UUID()
//    static let id4 = UUID()
//    static let id5 = UUID()
//
//    static func data() -> [Habit] {
//        let context = CoreDataManager.previews.mainContext
//
//        let h1 = try? Habit(context: context, name: "Swimming", id: id1)
//        h1?.markCompleted(on: Cal.date(byAdding: .day, value: -3, to: Date())!)
//        h1?.markCompleted(on: Cal.date(byAdding: .day, value: 0, to: Date())!)
//        h1?.markCompleted(on: Cal.date(byAdding: .day, value: -1, to: Date())!)
//
//        let h2 = try? Habit(context: context, name: "Basketball (MWF)", id: id2)
//        h2?.updateFrequency(to: .specificWeekdays([.tuesday, .wednesday, .friday]))
//        h2?.markCompleted(on: Cal.add(days: -1))
//
//        let h3 = try? Habit(context: context, name: "Timed Habit", id: id3)
//        h3?.markCompleted(on: Cal.date(byAdding: .day, value: -3, to: Date())!)
//
//        if let h3 = h3 {
//            let _ = TimeTracker(context: context, habit: h3, goalTime: 10)
//        }
//
//        let h4 = try? Habit(context: context, name: "Twice A Day", frequency: .timesPerDay(2), id: id4)
//        h4?.markCompleted(on: Cal.date(byAdding: .day, value: -3, to: Date())!)
//        h4?.markCompleted(on: Cal.date(byAdding: .day, value: -2, to: Date())!)
//        h4?.markCompleted(on: Cal.date(byAdding: .day, value: -2, to: Date())!)
//
//        let in3daysWeedayInt = (Date().weekdayIndex + 4) % 7
//        let in3DaysWeekday = Weekday(in3daysWeedayInt)
//        let h5 = try? Habit(context: context, name: "3 tpw, reset in 3, done 2", frequency: .timesPerWeek(times: 3, resetDay: in3DaysWeekday), id: id5)
//
//        h5?.markCompleted(on: Cal.add(days: -1))
//        h5?.markCompleted(on: Cal.add(days: -2))
//
//        let habits = Habit.habits(from: context)
//        return habits
//    }
//
//    static var previews: some View {
//        let _ = data()
//        let moc = CoreDataManager.previews.mainContext
//        HabitRowPreviewer(vm: HabitListViewModel(moc))
//    }
//}
