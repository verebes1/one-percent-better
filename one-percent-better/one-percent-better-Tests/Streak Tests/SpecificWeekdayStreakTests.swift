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
    
    /// Test one day a week. Mark it completed the first week, but don't the second
    func testStreakLabel1() {
        let vm = HabitRowViewModel(moc: context, habit: habit, sdvm: SelectedDateViewModel())
        let startDate = df.date(from: "8-21-2023")!
        habit.updateStartDate(to: startDate)
        habit.updateFrequency(to: .specificWeekdays([Weekday(df.date(from: "8-22-2023")!)]), on: startDate)
        habit.markCompleted(on: df.date(from: "8-22-2023")!)
        
        /*
         Week 1
         Date     | Due  | Did  |  Streak label
         -----------------------------------------
         8/21  M  |      |      |  No streak
         8/22  T  |  ⏰  |  ✅  |  1 week streak
         8/23  W  |      |      |  1 week streak
         8/24  T  |      |      |  1 week streak
         8/25  F  |      |      |  1 week streak
         8/26  S  |      |      |  1 week streak
         8/27  S  |      |      |  1 week streak
         */
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-21-2023")!)!.label, "No streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-22-2023")!)!.label, "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-23-2023")!)!.label, "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-24-2023")!)!.label, "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-25-2023")!)!.label, "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-26-2023")!)!.label, "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-27-2023")!)!.label, "1 week streak")
        
        /*
         Week 2
         Date     | Due  | Did  |  Streak label
         ------------------------------------------
         8/28  M  |      |      |  1 week streak
         8/29  T  |  ⏰  |      |  1 week streak
         8/30  W  |      |      |  1 week streak
         8/31  T  |      |      |  1 week streak
         9/1   F  |      |      |  1 week streak
         9/2   S  |      |      |  1 week streak
         9/3   S  |      |      |  1 week streak
         */
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-28-2023")!)!.label, "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-29-2023")!)!.label, "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-30-2023")!)!.label, "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-31-2023")!)!.label, "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-1-2023")!)!.label,  "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-2-2023")!)!.label,  "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-3-2023")!)!.label,  "1 week streak")
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
         8/22  T  |  ⏰  |      |  No streak
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
         8/29  T  |  ⏰  |  ✅  |  1 week streak
         8/30  W  |      |      |  1 week streak
         8/31  T  |      |      |  1 week streak
         9/1   F  |      |      |  1 week streak
         9/2   S  |      |      |  1 week streak
         9/3   S  |      |      |  1 week streak
         */
        habit.markCompleted(on: df.date(from: "8-29-2023")!)
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-28-2023")!)!.label, "No streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-29-2023")!)!.label, "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-30-2023")!)!.label, "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-31-2023")!)!.label, "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-1-2023")!)!.label,  "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-2-2023")!)!.label,  "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-3-2023")!)!.label,  "1 week streak")
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
         8/22  T  |  ⏰  |      |  No streak
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
         8/29  T  |  ⏰  |  ✅  |  1 week streak
         8/30  W  |      |      |  1 week streak
         8/31  T  |      |      |  1 week streak
         9/1   F  |      |      |  1 week streak
         9/2   S  |      |      |  1 week streak
         9/3   S  |      |      |  1 week streak
         */
        habit.markCompleted(on: df.date(from: "8-29-2023")!)
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-28-2023")!)!.label, "No streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-29-2023")!)!.label, "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-30-2023")!)!.label, "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-31-2023")!)!.label, "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-1-2023")!)!.label,  "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-2-2023")!)!.label,  "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-3-2023")!)!.label,  "1 week streak")
    }
    
    /// Test due 3 times a week, but only complete it once or twice and week and test "Not done in X weeks" label
    func testStreakLabel4() {
        StartOfWeekModel.shared.startOfWeek = .monday
        let vm = HabitRowViewModel(moc: context, habit: habit, sdvm: SelectedDateViewModel())
        let startDate = df.date(from: "8-21-2023")!
        habit.updateStartDate(to: startDate)
        habit.updateFrequency(to: .specificWeekdays([Weekday(df.date(from: "8-22-2023")!), Weekday(df.date(from: "8-24-2023")!), Weekday(df.date(from: "8-26-2023")!)]), on: startDate)
        habit.markCompleted(on: df.date(from: "8-22-2023")!)
        habit.markCompleted(on: df.date(from: "8-24-2023")!)
        habit.markCompleted(on: df.date(from: "8-26-2023")!)
        
        /*
         Week 1
         ➡️ = start of week
         Date     | Due  | Did  |  Streak label
         ----------------------------------------
         8/21  M  |  ➡️  |      |  No streak
         8/22  T  |  ⏰  |  ✅  |  No streak
         8/23  W  |      |      |  No streak
         8/24  T  |  ⏰  |  ✅  |  No streak
         8/25  F  |      |      |  No streak
         8/26  S  |  ⏰  |  ✅  |  1 week streak
         8/27  S  |      |      |  1 week streak
         */
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-21-2023")!)!.label, "No streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-22-2023")!)!.label, "No streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-23-2023")!)!.label, "No streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-24-2023")!)!.label, "No streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-25-2023")!)!.label, "No streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-26-2023")!)!.label, "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-27-2023")!)!.label, "1 week streak")
        
        /*
         Week 2
         Date     | Due  | Did  |  Streak label
         ----------------------------------------
         8/28  M  |  ➡️  |      |  1 week streak
         8/29  T  |  ⏰  |      |  1 week streak
         8/30  W  |      |      |  1 week streak
         8/31  T  |  ⏰  |      |  1 week streak
         9/1   F  |      |      |  1 week streak
         9/2   S  |  ⏰  |      |  1 week streak
         9/3   S  |      |      |  1 week streak
         */
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-28-2023")!)!.label, "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-29-2023")!)!.label, "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-30-2023")!)!.label, "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-31-2023")!)!.label, "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-1-2023")!)!.label,  "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-2-2023")!)!.label,  "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-3-2023")!)!.label,  "1 week streak")
        
        /*
         Week 3
         Date     | Due  | Did  |  Streak label
         ----------------------------------------
         9/4   M  |  ➡️  |      |  Not done in 1 week
         9/5   T  |  ⏰  |      |  Not done in 1 week
         9/6   W  |      |      |  Not done in 1 week
         9/7   T  |  ⏰  |      |  Not done in 1 week
         9/8   F  |      |      |  Not done in 1 week
         9/9   S  |  ⏰  |      |  Not done in 1 week
         9/10  S  |      |      |  Not done in 1 week
         */
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-4-2023")!)!.label,  "Not done in 1 week")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-5-2023")!)!.label,  "Not done in 1 week")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-6-2023")!)!.label,  "Not done in 1 week")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-7-2023")!)!.label,  "Not done in 1 week")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-8-2023")!)!.label,  "Not done in 1 week")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-9-2023")!)!.label,  "Not done in 1 week")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-10-2023")!)!.label, "Not done in 1 week")
        
        /*
         Week 4
         Date     | Due  | Did  |  Streak label
         ----------------------------------------
         9/11  M  |  ➡️  |      |  Not done in 2 weeks
         9/12  T  |  ⏰  |      |  Not done in 2 weeks
         9/13  W  |      |      |  Not done in 2 weeks
         9/14  T  |  ⏰  |      |  Not done in 2 weeks
         9/15  F  |      |      |  Not done in 2 weeks
         9/16  S  |  ⏰  |      |  Not done in 2 weeks
         9/17  S  |      |      |  Not done in 2 weeks
         */
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-11-2023")!)!.label, "Not done in 2 weeks")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-12-2023")!)!.label, "Not done in 2 weeks")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-13-2023")!)!.label, "Not done in 2 weeks")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-14-2023")!)!.label, "Not done in 2 weeks")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-15-2023")!)!.label, "Not done in 2 weeks")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-16-2023")!)!.label, "Not done in 2 weeks")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-17-2023")!)!.label, "Not done in 2 weeks")
    }
    
    /// Test due 2 times a week, and complete it on off days
    func testStreakLabel5() {
        StartOfWeekModel.shared.startOfWeek = .monday
        let vm = HabitRowViewModel(moc: context, habit: habit, sdvm: SelectedDateViewModel())
        let startDate = df.date(from: "8-21-2023")!
        habit.updateStartDate(to: startDate)
        habit.updateFrequency(to: .specificWeekdays([Weekday(df.date(from: "8-21-2023")!), Weekday(df.date(from: "8-22-2023")!)]), on: startDate)
        habit.markCompleted(on: df.date(from: "8-21-2023")!)
        habit.markCompleted(on: df.date(from: "8-22-2023")!)
        habit.markCompleted(on: df.date(from: "9-6-2023")!)
        habit.markCompleted(on: df.date(from: "9-9-2023")!)
        
        /*
         Week 1
         Date     | Due  | Did  |  Streak label
         ----------------------------------------
         8/21  M  |➡️⏰  |  ✅  |  No streak
         8/22  T  |  ⏰  |  ✅  |  1 week streak
         8/23  W  |      |      |  1 week streak
         8/24  T  |      |      |  1 week streak
         8/25  F  |      |      |  1 week streak
         8/26  S  |      |      |  1 week streak
         8/27  S  |      |      |  1 week streak
         */
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-21-2023")!)!.label, "No streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-22-2023")!)!.label, "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-23-2023")!)!.label, "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-24-2023")!)!.label, "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-25-2023")!)!.label, "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-26-2023")!)!.label, "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-27-2023")!)!.label, "1 week streak")
        
        /*
         Week 2
         Date     | Due  | Did  |  Streak label
         ----------------------------------------
         8/28  M  |➡️⏰  |      |  1 week streak
         8/29  T  |  ⏰  |      |  1 week streak
         8/30  W  |      |      |  1 week streak
         8/31  T  |      |      |  1 week streak
         9/1   F  |      |      |  1 week streak
         9/2   S  |      |      |  1 week streak
         9/3   S  |      |      |  1 week streak
         */
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-28-2023")!)!.label, "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-29-2023")!)!.label, "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-30-2023")!)!.label, "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "8-31-2023")!)!.label, "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-1-2023")!)!.label,  "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-2-2023")!)!.label,  "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-3-2023")!)!.label,  "1 week streak")
        
        /*
         Week 3
         Date     | Due  | Did  |  Streak label
         ----------------------------------------
         9/4   M  |➡️⏰  |      |  Not done in 1 week
         9/5   T  |  ⏰  |      |  Not done in 1 week
         9/6   W  |      |  ✅  |  Not done in 1 week
         9/7   T  |      |      |  Not done in 1 week
         9/8   F  |      |      |  Not done in 1 week
         9/9   S  |      |  ✅  |  1 week streak
         9/10  S  |      |      |  1 week streak
         */
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-4-2023")!)!.label,  "Not done in 1 week")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-5-2023")!)!.label,  "Not done in 1 week")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-6-2023")!)!.label,  "Not done in 1 week")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-7-2023")!)!.label,  "Not done in 1 week")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-8-2023")!)!.label,  "Not done in 1 week")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-9-2023")!)!.label,  "1 week streak")
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "9-10-2023")!)!.label, "1 week streak")
    }
}
