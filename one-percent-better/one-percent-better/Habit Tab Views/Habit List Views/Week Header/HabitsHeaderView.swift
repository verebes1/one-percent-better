//
//  HabitsHeaderView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/3/22.
//

import SwiftUI
import CoreData
import Combine

class SelectedDateViewModel: ObservableObject {
    
    /// The selected date
    @Published var selectedDate = Date()
    
    /// The latest day that has been shown. This is updated when the
    /// app is opened or the view appears on a new day.
    @Published var latestDay = Date()
    
    lazy var dateTitleFormatter: DateFormatter = {
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.locale = Locale.autoupdatingCurrent
        df.setLocalizedDateFormatFromTemplate("EEEE, MMM d, YYYY")
        return df
    }()
    
    var navTitle: String {
        dateTitleFormatter.string(from: selectedDate)
    }
    
    let hwvm: HeaderWeekViewModel
    
    init(hwvm: HeaderWeekViewModel) {
        self.hwvm = hwvm
        hwvm.sdvm = self
        hwvm.updateSelectedWeek(selectedDate: selectedDate)
        hwvm.updateImprovementScores(on: selectedDate)
    }
    
    func updateSelectedDay(to day: Date) {
        selectedDate = day
        hwvm.updateSelectedWeek(selectedDate: selectedDate)
        hwvm.updateImprovementScores(on: selectedDate)
    }
    
    func updateSelectedDayToToday() {
        if !Cal.isDate(latestDay, inSameDayAs: Date()) {
            latestDay = Date()
            updateSelectedDay(to: Date())
        }
    }
}

class HeaderWeekViewModel: ConditionalManagedObjectFetcher<Habit> {
    
    @Published var habits: [Habit] = []
    
    /// The week index of the selected week in the header view,
    /// ranging from 0 to n, where 0 is the earliest week, and n is the current week
    @Published var selectedWeekIndex = 0
    
    weak var sdvm: SelectedDateViewModel!
    
    init(_ context: NSManagedObjectContext = CoreDataManager.shared.mainContext) {
        super.init(context)
        habits = fetchedObjects
    }
    
    override func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        habits = controller.fetchedObjects as? [Habit] ?? []
    }
    
    func updateImprovementScores(on date: Date) {
        for habit in habits {
            habit.improvementTracker?.update(on: date)
        }
    }
    
    var earliestStartDate: Date {
        habits.earliestStartDate
    }
    
    /// The number of scrollable weeks from today to the earliest completed habit
    var numWeeksSinceEarliestCompletedHabit: Int {
        // Get the day which is aligned with the start of the week relative to today
        let todayStartOfWeek = Cal.add(days: -Date().weekdayIndex)
        
        // Get the day which is aligned with the start of the week relative to the earliest start date
        let earliestStartOfWeek = Cal.add(days: -earliestStartDate.weekdayIndex, to: earliestStartDate)
        
        // Calculate the difference
        let numDays = Cal.numberOfDays(from: earliestStartOfWeek, to: todayStartOfWeek)
        
        // Calculate the number of weeks
        let weeks = numDays / 7
        return weeks
    }
    
    /// Given a week index and a weekday index, calculate an offset to a reference day
    /// - Parameters:
    ///   - weekIndex: Week index: 0 == earliest week, numWeeksSinceEarliestCompletedHabit == latest week
    ///   - weekdayIndex: Weekday index: [0,1,2,3,4,5,6]
    ///   - referenceDay: The reference day to calculate the offset from
    /// - Returns: Integer offset from reference day. The day before the reference day is -1, the day of the reference day is 0, the day after the reference day is 1, etc.
    func dayOffset(weekIndex: Int, weekdayIndex: Int, from referenceDay: Date = Date()) -> Int {
        let numDaysBack = weekdayIndex - referenceDay.weekdayIndex
        let numWeeksBack = weekIndex - self.weekIndex(for: referenceDay)
        return (numWeeksBack * 7) + numDaysBack
    }
    
    /// The week index for a particular day
    /// - Parameter day: The day
    /// - Returns: The week index
    func weekIndex(for day: Date) -> Int {
        let weekDayOffset = day.weekdayIndex
        let totalDayOffset = -(Cal.numberOfDays(from: day, to: Date()))
        let weekNum = (weekDayOffset - totalDayOffset) / 7
        let result = numWeeksSinceEarliestCompletedHabit - weekNum
        return result
    }
    
    func date(weekIndex: Int, weekdayIndex: Int) -> Date {
        let offset = dayOffset(weekIndex: weekIndex, weekdayIndex: weekdayIndex)
        return Cal.add(days: offset)
    }
    
    func updateSelectedWeek(selectedDate: Date) {
        let newSelectedWeek = weekIndex(for: selectedDate)
        if selectedWeekIndex != newSelectedWeek {
            selectedWeekIndex = newSelectedWeek
        }
    }
    
    func selectedWeekChanged(to newWeek: Int) {
        let today = Date()
        let newSelectedDay = date(weekIndex: newWeek, weekdayIndex: sdvm.selectedDate.weekdayIndex)
        
        if newSelectedDay.startOfDay > today.startOfDay {
            // If scrolling to a day ahead of today
            sdvm.selectedDate = today
        } else if newSelectedDay.startOfDay < habits.earliestStartDate.startOfDay {
            // If scrolling to a day before the earliest start date
            sdvm.selectedDate = habits.earliestStartDate
        } else {
            sdvm.selectedDate = newSelectedDay
        }
    }
}

struct HabitsHeaderView: View {
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var hwvm: HeaderWeekViewModel
    @EnvironmentObject var sdvm: SelectedDateViewModel
    var color: Color = .systemTeal
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.mainContext) {
        print("Habit header view init")
    }
    
    func isToday(weekday: Weekday) -> Bool {
        let dayIsSelectedWeekday = Date().weekdayIndex == weekday.index
        let weekIsSelectedWeek = hwvm.selectedWeekIndex == hwvm.numWeeksSinceEarliestCompletedHabit
        return dayIsSelectedWeekday && weekIsSelectedWeek
    }
    
    /// If day can be selected (is within range)
    /// - Parameter day: The day to select
    func canSelect(day: Date) -> Bool {
        return day.startOfDay <= Date().startOfDay &&
        day.startOfDay >= hwvm.habits.earliestStartDate.startOfDay
    }
    
    /// Select a new date
    /// - Parameter day: The day to select
    func select(day: Date) {
        if canSelect(day: day) &&
            day != sdvm.selectedDate {
            sdvm.selectedDate = day
        }
    }
    
    var body: some View {
        let _ = Self._printChanges()
        VStack(spacing: 0) {
            HStack {
                ForEach(Weekday.orderedCases) { weekday in
                    SelectedDayView(weekday: weekday,
                                    selectedWeekday: Weekday(sdvm.selectedDate),
                                    isToday: isToday(weekday: weekday))
                    .onTapGesture {
                        let newDate = hwvm.date(weekIndex: hwvm.selectedWeekIndex, weekdayIndex: weekday.index)
                        select(day: newDate)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            let ringSize: CGFloat = 27
            TabView(selection: $hwvm.selectedWeekIndex) {
                ForEach(0 ... hwvm.numWeeksSinceEarliestCompletedHabit, id: \.self) { week in
                    HStack {
                        ForEach(Weekday.orderedCases) { weekday in
                            let day = hwvm.date(weekIndex: week, weekdayIndex: weekday.index)
                            RingView(percent: hwvm.habits.percentCompletion(on: day),
                                     color: color,
                                     size: ringSize,
                                     withText: true)
                            .font(.system(size: 14))
                            .frame(maxWidth: .infinity)
                            .onTapGesture {
                                select(day: day)
                            }
                            .contentShape(Rectangle())
                            .opacity(canSelect(day: day) ? 1 : 0.3)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .frame(height: ringSize + 22)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onChange(of: hwvm.selectedWeekIndex) { newWeek in
                hwvm.selectedWeekChanged(to: newWeek)
            }
        }
        
    }
    
}

struct HabitsListHeaderView_Previews: PreviewProvider {
    
    @State static var currentDay = Date()
    
    static func habitsListHeaderData() -> [Habit] {
        let context = CoreDataManager.previews.mainContext
        
        let day0 = Date()
        let day1 = Cal.date(byAdding: .day, value: -1, to: day0)!
        let day2 = Cal.date(byAdding: .day, value: -9, to: day0)!
        
        let h1 = try? Habit(context: context, name: "Cook")
        h1?.markCompleted(on: day0)
        h1?.markCompleted(on: day1)
        h1?.markCompleted(on: day2)
        
        let h2 = try? Habit(context: context, name: "Clean")
        h2?.markCompleted(on: day1)
        h2?.markCompleted(on: day2)
        
        let h3 = try? Habit(context: context, name: "Laundry")
        h3?.markCompleted(on: day2)
        
        let habits = Habit.habits(from: context)
        return habits
    }
    
    static var previews: some View {
        let moc = CoreDataManager.previews.mainContext
        let hwvm = HeaderWeekViewModel(moc)
        let sdvm = SelectedDateViewModel(hwvm: hwvm)
        HabitsHeaderView(context: moc)
            .environment(\.managedObjectContext, moc)
            .environmentObject(hwvm)
            .environmentObject(sdvm)
    }
}
