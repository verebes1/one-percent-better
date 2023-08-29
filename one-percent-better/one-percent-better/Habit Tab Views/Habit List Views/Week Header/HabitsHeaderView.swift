//
//  HabitsHeaderView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/3/22.
//

import SwiftUI
import CoreData
import Combine

class HeaderSelectionViewModel: ObservableObject {
    
    /// The week index of the selected week in the header view,
    /// ranging from 0 to n, where 0 is the earliest week, and n is the current week
    @Published var selectedWeekIndex = 0
    
    /// The selected date
    @Published var selectedDate = Date()
    
    /// The latest day that has been shown. This is updated when the
    /// app is opened or the view appears on a new day.
    @Published var latestDay = Date()
    
    var dateTitleFormatter: DateFormatter = {
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
        updateSelectedWeek()
        hwvm.updateImprovementScores(on: selectedDate)
    }
    
    func updateSelectedWeek() {
        let newSelectedWeek = hwvm.weekIndex(for: selectedDate)
        if self.selectedWeekIndex != newSelectedWeek {
            self.selectedWeekIndex = newSelectedWeek
        }
    }
    
    func updateSelectedDay(to day: Date) {
        selectedDate = day
        updateSelectedWeek()
        hwvm.updateImprovementScores(on: selectedDate)
    }
    
    func updateSelectedDayToToday() {
        if !Cal.isDate(latestDay, inSameDayAs: Date()) {
            latestDay = Date()
            updateSelectedDay(to: Date())
        }
    }
    
    func selectedWeekChanged(to newWeek: Int) {
        let today = Date()
        let newSelectedDay = hwvm.date(weekIndex: newWeek, weekdayIndex: selectedDate.weekdayIndex)
        
        if newSelectedDay.startOfDay() > today.startOfDay() {
            // If scrolling to week which has dates ahead of today
            selectedDate = today
        } else if newSelectedDay.startOfDay() < hwvm.earliestStartDate.startOfDay() {
            // If scrolls to week which has days before the earliest start date
            selectedDate = hwvm.earliestStartDate
        } else {
            selectedDate = newSelectedDay
        }
    }
}

class HeaderWeekViewModel: ConditionalManagedObjectFetcher<Habit> {
    
    @Published var habits: [Habit] = []
    
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
    
    /// The number of weeks from today to the earliest completed habit
    var numWeeksSinceEarliestCompletedHabit: Int {
        let numDays = Cal.dateComponents([.day], from: earliestStartDate, to: Date()).day!
        let diff = numDays - Date().weekdayIndex + 6
        let weeks = diff / 7
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
        let totalDayOffset = -(Cal.numberOfDaysBetween(day, and: Date()))
        let weekNum = (weekDayOffset - totalDayOffset) / 7
        let result = numWeeksSinceEarliestCompletedHabit - weekNum
        return result
    }
    
    func dayOffsetToToday(from date: Date) -> Int {
        let result = -(Cal.numberOfDaysBetween(date, and: Date()))
        return result
    }
    
    func date(weekIndex: Int, weekdayIndex: Int) -> Date {
        let offset = dayOffset(weekIndex: weekIndex, weekdayIndex: weekdayIndex)
        return Cal.add(days: offset)
    }
    
    /// Get the percent completion of all habits on this day
    /// - Parameter day: The day to calculate the percent completion for
    /// - Returns: The percent completion as a decimal in range [0,1]
    func percent(on day: Date) -> Double {
        var numCompleted: Double = 0
        var total: Double = 0
        for habit in habits {
            if Cal.startOfDay(for: habit.startDate) <= Cal.startOfDay(for: day),
               habit.isDue(on: day) {
                total += 1
            }
        }
        guard total > 0 else { return 0 }
        
        for habit in habits {
            if Cal.startOfDay(for: habit.startDate) <= Cal.startOfDay(for: day),
               habit.isDue(on: day) {
                numCompleted += habit.percentCompleted(on: day)
            }
        }
        return numCompleted / total
    }
}

struct HabitsHeaderView: View {
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var vm: HeaderWeekViewModel
    @EnvironmentObject var hsvm: HeaderSelectionViewModel
    var color: Color = .systemTeal
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.mainContext) {
        print("Habit header view init")
    }
    
    func isToday(weekday: Weekday) -> Bool {
        let dayIsSelectedWeekday = Date().weekdayIndex == weekday.index
        let weekIsSelectedWeek = hsvm.selectedWeekIndex == vm.numWeeksSinceEarliestCompletedHabit
        return dayIsSelectedWeekday && weekIsSelectedWeek
    }
    
    var body: some View {
        let _ = Self._printChanges()
        VStack(spacing: 0) {
            HStack {
                ForEach(Weekday.orderedCases) { weekday in
                    SelectedDayView(weekday: weekday,
                                    selectedWeekday: Weekday(hsvm.selectedDate),
                                    isToday: isToday(weekday: weekday))
                    .onTapGesture {
                        let weekdayIndex = weekday.index
                        let newDate = vm.date(weekIndex: hsvm.selectedWeekIndex, weekdayIndex: weekdayIndex)
                        if newDate.startOfDay() <= Date().startOfDay() &&
                            newDate.startOfDay() >= vm.earliestStartDate.startOfDay() &&
                            newDate != hsvm.selectedDate {
                            hsvm.selectedDate = newDate
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            
            let ringSize: CGFloat = 27
            TabView(selection: $hsvm.selectedWeekIndex) {
                ForEach(0 ... vm.numWeeksSinceEarliestCompletedHabit, id: \.self) { week in
                    HStack {
                        ForEach(Weekday.orderedCases) { weekday in
                            let dayOffset = vm.dayOffset(weekIndex: week, weekdayIndex: weekday.index)
                            let dayOffsetFromEarliest = vm.dayOffset(weekIndex: week, weekdayIndex: weekday.index, from: vm.earliestStartDate)
                            let percent = vm.percent(on: vm.date(weekIndex: week, weekdayIndex: weekday.index))
                            RingView(percent: percent,
                                     color: color,
                                     size: ringSize,
                                     withText: true)
                            .font(.system(size: 14))
                            .frame(maxWidth: .infinity)
                            .onTapGesture {
                                if dayOffset <= 0 && dayOffsetFromEarliest >= 0 {
                                    hsvm.selectedDate = Cal.add(days: dayOffset)
                                }
                            }
                            .contentShape(Rectangle())
                            .opacity((dayOffset > 0 || dayOffsetFromEarliest < 0) ? 0.4 : 1)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .frame(height: ringSize + 22)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onChange(of: hsvm.selectedWeekIndex) { newWeek in
                hsvm.selectedWeekChanged(to: newWeek)
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
        let hsvm = HeaderSelectionViewModel(hwvm: hwvm)
        HabitsHeaderView(context: moc)
            .environment(\.managedObjectContext, moc)
            .environmentObject(hwvm)
            .environmentObject(hsvm)
    }
}
