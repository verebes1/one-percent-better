//
//  HabitsHeaderView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/3/22.
//

import SwiftUI
import CoreData
import Combine

class HeaderWeekViewModel: ConditionalManagedObjectFetcher<Habit> {
    
    @Published var habits: [Habit] = []
    
    /// The week index of the selected week in the header view,
    /// ranging from 0 to n, where 0 is the earliest week, and n is the current week
    @Published var selectedWeekIndex: Int = 0
    
    let sdvm: SelectedDateViewModel
    
    /// The user preference for the start of the week
    var startOfWeek: Weekday
    
    private var cancelBag: Set<AnyCancellable> = []
    
    init(_ context: NSManagedObjectContext = CoreDataManager.shared.mainContext,
         sdvm: SelectedDateViewModel,
         sowm: StartOfWeekModel) {
        self.sdvm = sdvm
        self.startOfWeek = sowm.startOfWeek
        super.init(context)
        habits = fetchedObjects
        newDayUpdate(to: sdvm.selectedDate)
        
        // Subscribe to start of week from StartOfWeekModel
        sowm.$startOfWeek.sink { newWeekday in
            self.startOfWeek = newWeekday
            self.newDayUpdate(to: sdvm.selectedDate)
        }
        .store(in: &cancelBag)
    }
    
    override func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        habits = controller.fetchedObjects as? [Habit] ?? []
    }
    
    /// Update selected week index and improvement scores to new day
    func newDayUpdate(to selectedDate: Date) {
        selectedWeekIndex = weekIndex(for: selectedDate)
        updateImprovementScores(on: selectedDate)
    }
    
    /// Update the improvement scores because it's a new day
    func updateImprovementScores(on date: Date) {
        for habit in habits {
            habit.improvementTracker?.update(on: date)
        }
    }
    
    /// Check if it's a new day to update the latest day
    func checkForNewDay() {
        let today = Date()
        if !Cal.isDate(sdvm.latestDay, inSameDayAs: today) {
            sdvm.latestDay = today
            sdvm.selectedDate = today
            newDayUpdate(to: today)
        }
    }
    
    /// The earliest start date across all habits
    var earliestStartDate: Date {
        habits.earliestStartDate
    }
    
    /// Get the week index for a particular day
    func weekIndex(for day: Date) -> Int {
        // Get the day which is aligned with the start of the week relative to the given day
        let dayStartOfWeek = Cal.add(days: -day.weekdayIndex(startOfWeek), to: day)
        
        // Get the day which is aligned with the start of the week relative to the earliest start date
        let earliestStartOfWeek = Cal.add(days: -earliestStartDate.weekdayIndex(startOfWeek), to: earliestStartDate)
        
        // Calculate the difference
        let numDays = Cal.numberOfDays(from: earliestStartOfWeek, to: dayStartOfWeek)
        
        // Calculate the number of weeks
        let weeks = numDays / 7
        return weeks
    }
    
    /// The total number of scrollable weeks
    var totalNumWeeks: Int {
        weekIndex(for: Date())
    }
    
    /// Given a week index and a weekday index, calculate an offset to a reference day
    /// - Returns: Integer offset from reference day. The day before the reference day is -1, the day of the reference day is 0, the day after the reference day is 1, etc.
    func dayOffset(weekIndex: Int, weekdayIndex: Int, from referenceDay: Date = Date()) -> Int {
        let numDaysBack = weekdayIndex - referenceDay.weekdayIndex(startOfWeek)
        let numWeeksBack = weekIndex - self.weekIndex(for: referenceDay)
        return (numWeeksBack * 7) + numDaysBack
    }
    
    /// Get the date given the week index and weekday index
    func date(weekIndex: Int, weekdayIndex: Int) -> Date {
        let offset = dayOffset(weekIndex: weekIndex, weekdayIndex: weekdayIndex)
        return Cal.add(days: offset)
    }
    
    /// Update the selected week based on a new selected date
    func updateSelectedWeek(to selectedDate: Date) {
        let newSelectedWeek = weekIndex(for: selectedDate)
        if selectedWeekIndex != newSelectedWeek {
            selectedWeekIndex = newSelectedWeek
        }
    }
    
    /// If the weekday of the currently selected week is today or not
    func isToday(_ weekday: Weekday) -> Bool {
        let dayIsSelectedWeekday = Date().weekdayIndex(startOfWeek) == weekday.index(startOfWeek)
        let weekIsSelectedWeek = selectedWeekIndex == totalNumWeeks
        return dayIsSelectedWeekday && weekIsSelectedWeek
    }
    
    /// If a day can be selected (is within range)
    func canSelect(day: Date) -> Bool {
        return day.startOfDay <= Date().startOfDay &&
        day.startOfDay >= earliestStartDate.startOfDay
    }
    
    /// Select a new date
    func selectIfPossible(weekIndex: Int, weekdayIndex: Int) {
        let day = date(weekIndex: weekIndex, weekdayIndex: weekdayIndex)
        if canSelect(day: day) {
            sdvm.selectedDate = day
        }
    }
    
    /// Finds the nearest selectable date to the proposed date
    func nearestSelectableDate(to proposedDate: Date) -> Date {
        let today = Date()
        if proposedDate.startOfDay > today.startOfDay {
            // If scrolling to a day ahead of today
            return today
        } else if proposedDate.startOfDay < habits.earliestStartDate.startOfDay {
            // If scrolling to a day before the earliest start date
            return habits.earliestStartDate
        } else {
            return proposedDate
        }
    }
    
    /// Select the nearest selectable day for the proposed date
    func selectNearest(weekIndex: Int, weekdayIndex: Int) {
        let proposedDate = date(weekIndex: weekIndex, weekdayIndex: weekdayIndex)
        let selectableDate = nearestSelectableDate(to: proposedDate)
        sdvm.selectedDate = selectableDate
    }
}

struct HabitsHeaderView: View {
    
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var sdvm: SelectedDateViewModel
    @StateObject var hwvm: HeaderWeekViewModel
    @StateObject var sowm = StartOfWeekModel()
    
    let ringSize: CGFloat = 27
    
    var startOfWeek: Weekday {
        sowm.startOfWeek
    }
    
    init(sdvm: SelectedDateViewModel) {
        let sowm = StartOfWeekModel()
        self._sowm = StateObject(wrappedValue: sowm)
        self._hwvm = StateObject(wrappedValue: HeaderWeekViewModel(sdvm: sdvm, sowm: sowm))
    }
    
    var body: some View {
        let _ = Self.printChanges(self)
        VStack(spacing: 0) {
            HStack {
                ForEach(Weekday.orderedCases(startOfWeek)) { weekday in
                    SelectedDayView(weekday: weekday,
                                    selectedWeekday: Weekday(sdvm.selectedDate),
                                    isToday: hwvm.isToday(weekday))
                    .onTapGesture {
                        hwvm.selectIfPossible(weekIndex: hwvm.selectedWeekIndex, weekdayIndex: weekday.index(startOfWeek))
                    }
                }
            }
            .padding(.horizontal, 20)
            
            TabView(selection: $hwvm.selectedWeekIndex) {
                ForEach(0 ... hwvm.totalNumWeeks, id: \.self) { weekIndex in
                    HStack {
                        ForEach(Weekday.orderedCases(startOfWeek)) { weekday in
                            let day = hwvm.date(weekIndex: weekIndex, weekdayIndex: weekday.index(startOfWeek))
                            RingView(percent: hwvm.habits.percentCompletion(on: day),
                                     size: ringSize,
                                     withText: true)
                            .font(.system(size: 14))
                            .frame(maxWidth: .infinity)
                            .onTapGesture {
                                hwvm.selectIfPossible(weekIndex: weekIndex, weekdayIndex: weekday.index(startOfWeek))
                            }
                            .contentShape(Rectangle())
                            .opacity(hwvm.canSelect(day: day) ? 1 : 0.3)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .frame(height: ringSize + 22)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onChange(of: hwvm.selectedWeekIndex) { newWeekIndex in
                hwvm.selectNearest(weekIndex: newWeekIndex, weekdayIndex: sdvm.selectedDate.weekdayIndex(startOfWeek))
            }
        }
        .onAppear {
            hwvm.checkForNewDay()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                hwvm.checkForNewDay()
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
        let sdvm = SelectedDateViewModel()
        HabitsHeaderView(sdvm: sdvm)
            .environment(\.managedObjectContext, moc)
            .environmentObject(sdvm)
    }
}
