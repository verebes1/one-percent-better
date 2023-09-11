//
//  SpecificWeekdayStreakTests.swift
//  one-percent-betterTests
//
//  Created by Jeremy Cook on 5/15/23.
//

import XCTest
import CoreData
@testable import One_Percent_Better

final class SpecificWeekdayStreakTests: XCTestCase {
    
    let context = CoreDataManager.previews.mainContext
    
    var habit: Habit!
    
    var df: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "MM-dd-yyyy"
        return df
    }
    
    override func setUpWithError() throws {
        habit = try! Habit(context: context, name: "Cook")
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        let habits = Habit.habits(from: context)
        for habit in habits {
            context.delete(habit)
        }
        try context.save()
    }
    
    // MARK: Specific Weekday Tests
    
    func testSpecifificWeekdayStreak() {
        let startWednesday = df.date(from: "12-7-2022")!
        habit.updateStartDate(to: startWednesday)
        habit.updateFrequency(to: .specificWeekdays([.wednesday, .thursday]), on: startWednesday)
        
        XCTAssertEqual(habit.streak(on: startWednesday), 0)
        habit.markCompleted(on: startWednesday)
        XCTAssertEqual(habit.streak(on: startWednesday), 1)
        let thursday = Cal.add(days: 1, to: startWednesday)
        XCTAssertEqual(habit.streak(on: thursday), 1)
        XCTAssertEqual(habit.streak(on: Cal.add(days: 1, to: thursday)), 0)
        XCTAssertEqual(habit.streak(on: Cal.add(days: 2, to: thursday)), 0)
        
        habit.markCompleted(on: thursday)
        XCTAssertEqual(habit.streak(on: thursday), 2)
        XCTAssertEqual(habit.streak(on: Cal.add(days: 2, to: startWednesday)), 2) // friday
        XCTAssertEqual(habit.streak(on: Cal.add(days: 3, to: startWednesday)), 2) // saturday
        XCTAssertEqual(habit.streak(on: Cal.add(days: 4, to: startWednesday)), 2) // sunday
        XCTAssertEqual(habit.streak(on: Cal.add(days: 5, to: startWednesday)), 2) // monday
        XCTAssertEqual(habit.streak(on: Cal.add(days: 6, to: startWednesday)), 2) // tuesday
        XCTAssertEqual(habit.streak(on: Cal.add(days: 7, to: startWednesday)), 2) // wednesday (DUE)
        XCTAssertEqual(habit.streak(on: Cal.add(days: 8, to: startWednesday)), 0) // thursday (DUE)
        
        habit.markCompleted(on: Cal.add(days: 1, to: thursday))
        XCTAssertEqual(habit.streak(on: Cal.add(days: 1, to: startWednesday)), 2) // thursday
        XCTAssertEqual(habit.streak(on: Cal.add(days: 2, to: startWednesday)), 3) // friday
        XCTAssertEqual(habit.streak(on: Cal.add(days: 3, to: startWednesday)), 3) // saturday
        XCTAssertEqual(habit.streak(on: Cal.add(days: 4, to: startWednesday)), 3) // sunday
        XCTAssertEqual(habit.streak(on: Cal.add(days: 5, to: startWednesday)), 3) // monday
        XCTAssertEqual(habit.streak(on: Cal.add(days: 6, to: startWednesday)), 3) // tuesday
        XCTAssertEqual(habit.streak(on: Cal.add(days: 7, to: startWednesday)), 3) // wednesday (DUE)
        XCTAssertEqual(habit.streak(on: Cal.add(days: 8, to: startWednesday)), 0) // thursday (DUE)
    }
    
    
    func testSpecifificWeekdayStreak2() {
        let startMonday = df.date(from: "12-5-2022")!
        habit.updateStartDate(to: startMonday)
        habit.updateFrequency(to: .specificWeekdays([.sunday]), on: startMonday)
        
        XCTAssertEqual(habit.streak(on: Cal.add(days: 2, to: startMonday)), 0)
        XCTAssertEqual(habit.streak(on: Cal.add(days: 3, to: startMonday)), 0)
        XCTAssertEqual(habit.streak(on: Cal.add(days: 4, to: startMonday)), 0)
        
        habit.markCompleted(on: Cal.add(days: 1, to: startMonday))
        XCTAssertEqual(habit.streak(on: startMonday), 0)
        XCTAssertEqual(habit.streak(on: Cal.add(days: 1, to: startMonday)), 1) // tuesday
        XCTAssertEqual(habit.streak(on: Cal.add(days: 2, to: startMonday)), 1) // wednesday
        XCTAssertEqual(habit.streak(on: Cal.add(days: 3, to: startMonday)), 1) // thursday
        XCTAssertEqual(habit.streak(on: Cal.add(days: 4, to: startMonday)), 1) // friday
        XCTAssertEqual(habit.streak(on: Cal.add(days: 5, to: startMonday)), 1) // saturday
        XCTAssertEqual(habit.streak(on: Cal.add(days: 6, to: startMonday)), 1) // sunday (DUE)
        XCTAssertEqual(habit.streak(on: Cal.add(days: 7, to: startMonday)), 0) // monday
    }
    
    
    /// Test one day a week. Mark it completed the first week, but don't the second
    func testStreakLabel1() {
        let vm = HabitRowViewModel(moc: context, habit: habit, sdvm: SelectedDateViewModel())
        let startDate = df.date(from: "8-21-2023")!
        habit.updateStartDate(to: startDate)
        habit.updateFrequency(to: .specificWeekdays([Weekday(df.date(from: "8-22-2023")!)]), on: startDate)
        
        /*
         Week 1
         Date     | Due  | Did  |  Streak label
         ----------------------------------------
         8/21  M  |      |      |  No streak
         8/22  T  |  ⏰  |  ✅  |  1 day streak
         8/23  W  |      |      |   1 day streak
         8/24  T  |      |      |  1 day streak
         8/25  F  |      |      |  1 day streak
         8/26  S  |      |      |  1 day streak
         8/27  S  |      |      |  1 day streak
         */
        habit.markCompleted(on: df.date(from: "8-22-2023")!)
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-21-2023")!)!.label, "No streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-22-2023")!)!.label, "1 day streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-23-2023")!)!.label, "1 day streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-24-2023")!)!.label, "1 day streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-25-2023")!)!.label, "1 day streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-26-2023")!)!.label, "1 day streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-27-2023")!)!.label, "1 day streak")
        
        /*
         Week 2
         Date     | Due  | Did  |  Streak label
         ----------------------------------------
         8/28  M  |      |      |  1 day streak
         8/29  T  |  ⏰  |  ❌  |  1 day streak
         8/30  W  |      |      |  Not done in 1 week
         8/31  T  |      |      |  Not done in 1 week
         9/1   F  |      |      |  Not done in 1 week
         9/2   S  |      |      |  Not done in 1 week
         9/3   S  |      |      |  Not done in 1 week
         */
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-28-2023")!)!.label, "1 day streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-29-2023")!)!.label, "1 day streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-30-2023")!)!.label, "Not done in 1 week")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-31-2023")!)!.label, "Not done in 1 week")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-1-2023")!)!.label,  "Not done in 1 week")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-2-2023")!)!.label,  "Not done in 1 week")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-3-2023")!)!.label,  "Not done in 1 week")
    }
    
    /// Make sure no streak extends until the first time the user completes the habit
    func testStreakLabel2() {
        let vm = HabitRowViewModel(moc: context, habit: habit, sdvm: SelectedDateViewModel())
        let startDate = df.date(from: "8-21-2023")!
        habit.updateStartDate(to: startDate)
        habit.updateFrequency(to: .specificWeekdays([Weekday(df.date(from: "8-22-2023")!)]), on: startDate)
        
        /*
         Week 1
         Date     | Due  | Did  |  Streak label
         ----------------------------------------
         8/21  M  |      |      |  No streak
         8/22  T  |  ⏰  |  ❌  |  No streak
         8/23  W  |      |      |  No streak
         8/24  T  |      |      |  No streak
         8/25  F  |      |      |  No streak
         8/26  S  |      |      |  No streak
         8/27  S  |      |      |  No streak
         */
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-21-2023")!)!.label, "No streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-22-2023")!)!.label, "No streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-23-2023")!)!.label, "No streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-24-2023")!)!.label, "No streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-25-2023")!)!.label, "No streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-26-2023")!)!.label, "No streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-27-2023")!)!.label, "No streak")
        
        /*
         Week 2
         Date     | Due  | Did  |  Streak label
         ----------------------------------------
         8/28  M  |      |      |  No streak
         8/29  T  |  ⏰  |  ✅  |  1 day streak
         8/30  W  |      |      |  1 day streak
         8/31  T  |      |      |  1 day streak
         9/1   F  |      |      |  1 day streak
         9/2   S  |      |      |  1 day streak
         9/3   S  |      |      |  1 day streak
         */
        habit.markCompleted(on: df.date(from: "8-29-2023")!)
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-28-2023")!)!.label, "No streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-29-2023")!)!.label, "1 day streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-30-2023")!)!.label, "1 day streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-31-2023")!)!.label, "1 day streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-1-2023")!)!.label,  "1 day streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-2-2023")!)!.label,  "1 day streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-3-2023")!)!.label,  "1 day streak")
    }
    
    /// Make sure no streak extends until the first time the user completes the habit
    func testStreakLabel3() {
        let vm = HabitRowViewModel(moc: context, habit: habit, sdvm: SelectedDateViewModel())
        let startDate = df.date(from: "8-21-2023")!
        habit.updateStartDate(to: startDate)
        habit.updateFrequency(to: .specificWeekdays([Weekday(df.date(from: "8-22-2023")!)]), on: startDate)
        
        /*
         Week 1
         Date     | Due  | Did  |  Streak label
         ----------------------------------------
         8/21  M  |      |      |  No streak
         8/22  T  |  ⏰  |  ❌  |  No streak
         8/23  W  |      |      |  No streak
         8/24  T  |      |      |  No streak
         8/25  F  |      |      |  No streak
         8/26  S  |      |      |  No streak
         8/27  S  |      |      |  No streak
         */
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-21-2023")!)!.label, "No streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-22-2023")!)!.label, "No streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-23-2023")!)!.label, "No streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-24-2023")!)!.label, "No streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-25-2023")!)!.label, "No streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-26-2023")!)!.label, "No streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-27-2023")!)!.label, "No streak")
        
        /*
         Week 2
         Date     | Due  | Did  |  Streak label
         ----------------------------------------
         8/28  M  |      |      |  No streak
         8/29  T  |  ⏰  |  ✅  |  1 day streak
         8/30  W  |      |      |  1 day streak
         8/31  T  |      |      |  1 day streak
         9/1   F  |      |      |  1 day streak
         9/2   S  |      |      |  1 day streak
         9/3   S  |      |      |  1 day streak
         */
        habit.markCompleted(on: df.date(from: "8-29-2023")!)
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-28-2023")!)!.label, "No streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-29-2023")!)!.label, "1 day streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-30-2023")!)!.label, "1 day streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-31-2023")!)!.label, "1 day streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-1-2023")!)!.label,  "1 day streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-2-2023")!)!.label,  "1 day streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-3-2023")!)!.label,  "1 day streak")
    }
    
//    func testSpecifificWeekdayStreakLabel2() {
//        let today = Date()
//        let threeDaysAgo = Cal.add(days: -3)
//        let startDate = Cal.getLast(weekday: Weekday(today))
//        let specificWeekdays: Set<Weekday> = [Weekday(threeDaysAgo)]
//        habit.updateStartDate(to: startDate)
//        habit.updateFrequency(to: .specificWeekdays(specificWeekdays), on: startDate)
//
//        let sdvm = SelectedDateViewModel()
//        sdvm.selectedDate = today
//        let vm = HabitRowViewModel(moc: context, habit: habit, sdvm: sdvm)
//
//        // Never completed
//        XCTAssertEqual(vm.streakLabel()?.label, "No streak")
//
//        // Mark completed when it was due
//        habit.markCompleted(on: threeDaysAgo)
//        sdvm.selectedDate = threeDaysAgo
//        XCTAssertEqual(vm.streakLabel()?.label, "1 day streak")
//
//        sdvm.selectedDate = Cal.add(days: -2)
//        XCTAssertEqual(vm.streakLabel()?.label, "1 day streak")
//
//        sdvm.selectedDate = Cal.add(days: -1)
//        XCTAssertEqual(vm.streakLabel()?.label, "1 day streak")
//
//        sdvm.selectedDate = today
//        XCTAssertEqual(vm.streakLabel()?.label, "1 day streak")
//    }
//
//    func testSpecifificWeekdayStreakLabel3() {
//        let today = Date()
//        let threeDaysAgo = Cal.add(days: -3)
//        let yesterday = Cal.add(days: -1)
//        let startDate = Cal.getLast(weekday: Weekday(today))
//        let specificWeekdays: Set<Weekday> = [Weekday(threeDaysAgo), Weekday(yesterday)]
//        habit.updateStartDate(to: startDate)
//        habit.updateFrequency(to: .specificWeekdays(specificWeekdays), on: startDate)
//
//        let sdvm = SelectedDateViewModel()
//        sdvm.selectedDate = today
//        let vm = HabitRowViewModel(moc: context, habit: habit, sdvm: sdvm)
//
//        // Never completed
//        XCTAssertEqual(vm.streakLabel()?.label, "No streak")
//
//        // Mark completed when it was due
//        habit.markCompleted(on: threeDaysAgo)
//        sdvm.selectedDate = threeDaysAgo
//        XCTAssertEqual(vm.streakLabel()?.label, "1 day streak")
//
//        sdvm.selectedDate = Cal.add(days: -2)
//        XCTAssertEqual(vm.streakLabel()?.label, "1 day streak")
//
//        // Mark completed when it was due
//        habit.markCompleted(on: yesterday)
//        sdvm.selectedDate = yesterday
//        XCTAssertEqual(vm.streakLabel()?.label, "2 day streak")
//
//        sdvm.selectedDate = today
//        XCTAssertEqual(vm.streakLabel()?.label, "2 day streak")
//
//        // Mark completed when it wasn't due
//        habit.markCompleted(on: Cal.add(days: -2))
//        XCTAssertEqual(vm.streakLabel()?.label, "3 day streak")
//    }
//
    
    /// Test when to show "Not done in X days" when user stops doing a [M,W] habit
    ///
    /// Date       | Due | Did  |  Streak
    /// --------------------------
    /// 8/21  M  |  ⏰  |  ❌  |  No streak
    /// 8/22  T   |         |         |  No streak
    /// 8/23  W  |  ⏰  |  ✅  |  1 day streak
    /// 8/24  T   |         |         |  1 day streak
    /// 8/25  F   |         |         |  1 day streak
    /// 8/26  S   |         |         |  1 day streak
    /// 8/27  S   |         |         |  1 day streak
    ///
    /// Week 2
    /// --------------------------
    /// 8/28  M  |  ⏰  |  ❌  |  No streak
    /// 8/29  T   |         |         |  No streak
    /// 8/30  W  |  ⏰  |  ❌  |  No streak
    /// 8/31  T   |         |         |  No streak
    /// 9/1    F   |         |         |  No streak
    /// 9/2    S   |         |         |  No streak
    /// 9/3    S   |         |         |  No streak
    ///
    /// Week 3
    /// --------------------------
    /// 9/4    M  |  ⏰  |  ❌  |  No streak
    /// 9/5    T   |         |         |  Not done in 1 week
    /// 9/6    W  |  ⏰  |  ❌  |  Not done in 1 week
    /// 9/7    T   |         |         |  Not done in 1 week
    /// 9/8    F   |         |         |  Not done in 1 week
    /// 9/9    S   |         |         |  Not done in 1 week
    /// 9/10  S   |         |         |  Not done in 1 week
//    func testSpecifificWeekdayStreakLabel4() {
//        let startDate = df.date(from: "8-21-2023")
//        let fourDaysAgo = Cal.add(days: -4)
//        let twoDaysAgo = Cal.add(days: -2)
//        let yesterday = Cal.add(days: -1)
//        let startDate = Cal.getLast(weekday: Weekday(today))
//        let specificWeekdays: Set<Weekday> = [Weekday(fourDaysAgo), Weekday(twoDaysAgo)]
//        habit.updateStartDate(to: startDate)
//        habit.updateFrequency(to: .specificWeekdays(specificWeekdays), on: startDate)
//
//        let sdvm = SelectedDateViewModel()
//        sdvm.selectedDate = today
//        let vm = HabitRowViewModel(moc: context, habit: habit, sdvm: sdvm)
//
//        // Never completed
//        XCTAssertEqual(vm.streakLabel()?.label, "No streak")
//
//        // Mark completed when it was due
//        habit.markCompleted(on: fourDaysAgo)
//        sdvm.selectedDate = fourDaysAgo
//        XCTAssertEqual(vm.streakLabel()?.label, "1 day streak")
//
//        // Still have streak bc it's not due this day
//        sdvm.selectedDate = Cal.add(days: -3)
//        XCTAssertEqual(vm.streakLabel()?.label, "1 day streak")
//
//        // Do no mark completed when it was due
//        sdvm.selectedDate = twoDaysAgo
//        XCTAssertEqual(vm.streakLabel()?.label, "1 day streak")
//
//        // Streak is broken
//        sdvm.selectedDate = yesterday
//        XCTAssertEqual(vm.streakLabel()?.label, "No streak")
//
//        sdvm.selectedDate = today
//        XCTAssertEqual(vm.streakLabel()?.label, "No streak")
//
//        // Mark completed when it wasn't due
//        habit.markCompleted(on: Cal.add(days: -2))
//        XCTAssertEqual(vm.streakLabel()?.label, "3 day streak")
//    }
}
