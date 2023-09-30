//
//  NotDoneInTests.swift
//  one-percent-betterTests
//
//  Created by Jeremy Cook on 5/15/23.
//

import XCTest
import CoreData
@testable import One_Percent_Better

final class NotDoneInTests: XCTestCase {
    
    let context = CoreDataManager.previews.mainContext
    var habit: Habit!
    var startWednesday: Date = df.date(from: "12-7-2022")!
    var vm: HabitRowViewModel!
    var sdvm: SelectedDateViewModel!
    
    override func setUpWithError() throws {
        habit = try! Habit(context: context, name: "Cook")
        sdvm = SelectedDateViewModel()
        vm = HabitRowViewModel(moc: context, habit: habit, sdvm: sdvm)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        let habits = Habit.habits(from: context)
        for habit in habits {
            context.delete(habit)
        }
        try context.save()
    }
    
    func testOneTimePerWeek() throws {
        habit.updateStartDate(to: startWednesday)
        habit.updateFrequency(to: .timesPerWeek(times: 1, resetDay: .sunday), on: startWednesday)
        habit.markCompleted(on: df.date(from: "12-8-2022")!)
        
        /*
         Date         | Due  | Did  |  Streak label
         ------------------------------------------
         12/7    Wed  |      |      |  No streak
         12/8    Thu  |      |  ✅  |  1 week streak
         12/9    Fri  |      |      |  1 week streak
         12/10   Sat  |      |      |  1 week streak
         12/11   Sun  |  ⏰  |      |  1 week streak
         12/12   Mon  |      |      |  1 week streak
         12/13   Tue  |      |      |  1 week streak
         12/14   Wed  |      |      |  1 week streak
         12/15   Thu  |      |      |  1 week streak
         12/16   Fri  |      |      |  1 week streak
         12/17   Sat  |      |      |  1 week streak
         12/18   Sun  |  ⏰  |      |  Not done in 1 week
         12/19   Mon  |      |      |  Not done in 1 week
         */

        XCTAssertEqual(vm.streakLabel(on: df.date(from: "12-7-2022")!),  StreakLabel("No streak", StreakLabel.gray))
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "12-8-2022")!),  StreakLabel("1 week streak", .green))
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "12-8-2022")!),  StreakLabel("1 week streak", .green))
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "12-9-2022")!),  StreakLabel("1 week streak", .green))
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "12-10-2022")!), StreakLabel("1 week streak", .green))
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "12-11-2022")!), StreakLabel("1 week streak", .green))
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "12-12-2022")!), StreakLabel("1 week streak", .green))
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "12-13-2022")!), StreakLabel("1 week streak", .green))
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "12-14-2022")!), StreakLabel("1 week streak", .green))
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "12-15-2022")!), StreakLabel("1 week streak", .green))
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "12-16-2022")!), StreakLabel("1 week streak", .green))
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "12-17-2022")!), StreakLabel("1 week streak", .green))
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "12-18-2022")!), StreakLabel("Not done in 1 week", .red))
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "12-19-2022")!), StreakLabel("Not done in 1 week", .red))
        
        XCTAssertEqual(habit.notDoneInDays(on: df.date(from: "12-7-2022")!),  nil)
        XCTAssertEqual(habit.notDoneInDays(on: df.date(from: "12-8-2022")!),  0)
        XCTAssertEqual(habit.notDoneInDays(on: df.date(from: "12-9-2022")!),  1)
        XCTAssertEqual(habit.notDoneInDays(on: df.date(from: "12-10-2022")!), 2)
        XCTAssertEqual(habit.notDoneInDays(on: df.date(from: "12-11-2022")!), 3)
        XCTAssertEqual(habit.notDoneInDays(on: df.date(from: "12-12-2022")!), 4)
        XCTAssertEqual(habit.notDoneInDays(on: df.date(from: "12-13-2022")!), 5)
        XCTAssertEqual(habit.notDoneInDays(on: df.date(from: "12-14-2022")!), 6)
        XCTAssertEqual(habit.notDoneInDays(on: df.date(from: "12-15-2022")!), 7)
        XCTAssertEqual(habit.notDoneInDays(on: df.date(from: "12-16-2022")!), 8)
        XCTAssertEqual(habit.notDoneInDays(on: df.date(from: "12-17-2022")!), 9)
        XCTAssertEqual(habit.notDoneInDays(on: df.date(from: "12-18-2022")!), 10)
        XCTAssertEqual(habit.notDoneInDays(on: df.date(from: "12-19-2022")!), 11)
        
        XCTAssertEqual(habit.notDoneInWeeks(on: df.date(from: "12-7-2022")!),  nil)
        XCTAssertEqual(habit.notDoneInWeeks(on: df.date(from: "12-8-2022")!),  0)
        XCTAssertEqual(habit.notDoneInWeeks(on: df.date(from: "12-9-2022")!),  0)
        XCTAssertEqual(habit.notDoneInWeeks(on: df.date(from: "12-10-2022")!), 0)
        XCTAssertEqual(habit.notDoneInWeeks(on: df.date(from: "12-11-2022")!), 0)
        XCTAssertEqual(habit.notDoneInWeeks(on: df.date(from: "12-12-2022")!), 0)
        XCTAssertEqual(habit.notDoneInWeeks(on: df.date(from: "12-13-2022")!), 0)
        XCTAssertEqual(habit.notDoneInWeeks(on: df.date(from: "12-14-2022")!), 0)
        XCTAssertEqual(habit.notDoneInWeeks(on: df.date(from: "12-15-2022")!), 0)
        XCTAssertEqual(habit.notDoneInWeeks(on: df.date(from: "12-16-2022")!), 0)
        XCTAssertEqual(habit.notDoneInWeeks(on: df.date(from: "12-17-2022")!), 0)
        XCTAssertEqual(habit.notDoneInWeeks(on: df.date(from: "12-18-2022")!), 1)
        XCTAssertEqual(habit.notDoneInWeeks(on: df.date(from: "12-19-2022")!), 1)
    }
    
    func testOneTimePerWeek2() throws {
        habit.updateStartDate(to: startWednesday)
        habit.updateFrequency(to: .timesPerWeek(times: 1, resetDay: .sunday), on: startWednesday)
        habit.markCompleted(on: df.date(from: "12-8-2022")!)
        habit.markCompleted(on: df.date(from: "12-14-2022")!)
        
        // Due on day before "reset day", i.e. beginning day
        /*
         Date         | Due  | Did  |  Streak label
         ------------------------------------------
         12/7    Wed  |      |      |  No streak
         12/8    Thu  |      |  ✅  |  1 week streak
         12/9    Fri  |      |      |  1 week streak
         12/10   Sat  |      |      |  1 week streak
         12/11   Sun  |  ⏰  |      |  1 week streak
         12/12   Mon  |      |      |  1 week streak
         12/13   Tue  |      |      |  1 week streak
         12/14   Wed  |      |  ✅  |  2 week streak
         12/15   Thu  |      |      |  2 week streak
         12/16   Fri  |      |      |  2 week streak
         12/17   Sat  |      |      |  2 week streak
         12/18   Sun  |  ⏰  |      |  2 week streak
         12/19   Mon  |      |      |  2 week streak
         ...
         12/24   Sat  |      |      |  2 week streak
         12/25   Sun  |  ⏰  |      |  Not done in 1 week
         12/26   Mon  |      |      |  Not done in 1 week
         */

        // Test streak label
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "12-7-2022")!), StreakLabel("No streak", StreakLabel.gray))
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "12-8-2022")!), StreakLabel("1 week streak", .green))
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "12-8-2022")!), StreakLabel("1 week streak", .green))
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "12-9-2022")!), StreakLabel("1 week streak", .green))
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "12-10-2022")!), StreakLabel("1 week streak", .green))
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "12-11-2022")!), StreakLabel("1 week streak", .green))
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "12-12-2022")!), StreakLabel("1 week streak", .green))
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "12-13-2022")!), StreakLabel("1 week streak", .green))
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "12-14-2022")!), StreakLabel("2 week streak", .green))
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "12-15-2022")!), StreakLabel("2 week streak", .green))
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "12-16-2022")!), StreakLabel("2 week streak", .green))
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "12-17-2022")!), StreakLabel("2 week streak", .green))
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "12-18-2022")!), StreakLabel("2 week streak", .green))
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "12-19-2022")!), StreakLabel("2 week streak", .green))
        // ...
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "12-24-2022")!), StreakLabel("2 week streak", .green))
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "12-25-2022")!), StreakLabel("Not done in 1 week", .red))
        XCTAssertEqual(vm.streakLabel(on: df.date(from: "12-26-2022")!), StreakLabel("Not done in 1 week", .red))
        
        // Test not done in days
        XCTAssertEqual(habit.notDoneInDays(on: df.date(from: "12-7-2022")!), nil)
        XCTAssertEqual(habit.notDoneInDays(on: df.date(from: "12-8-2022")!), 0)
        XCTAssertEqual(habit.notDoneInDays(on: df.date(from: "12-9-2022")!), 1)
        XCTAssertEqual(habit.notDoneInDays(on: df.date(from: "12-10-2022")!), 2)
        XCTAssertEqual(habit.notDoneInDays(on: df.date(from: "12-11-2022")!), 3)
        XCTAssertEqual(habit.notDoneInDays(on: df.date(from: "12-12-2022")!), 4)
        XCTAssertEqual(habit.notDoneInDays(on: df.date(from: "12-13-2022")!), 5)
        XCTAssertEqual(habit.notDoneInDays(on: df.date(from: "12-14-2022")!), 0)
        XCTAssertEqual(habit.notDoneInDays(on: df.date(from: "12-15-2022")!), 1)
        XCTAssertEqual(habit.notDoneInDays(on: df.date(from: "12-16-2022")!), 2)
        XCTAssertEqual(habit.notDoneInDays(on: df.date(from: "12-17-2022")!), 3)
        XCTAssertEqual(habit.notDoneInDays(on: df.date(from: "12-18-2022")!), 4)
        XCTAssertEqual(habit.notDoneInDays(on: df.date(from: "12-19-2022")!), 5)
        // ...
        XCTAssertEqual(habit.notDoneInDays(on: df.date(from: "12-24-2022")!), 10)
        XCTAssertEqual(habit.notDoneInDays(on: df.date(from: "12-25-2022")!), 11)
        XCTAssertEqual(habit.notDoneInDays(on: df.date(from: "12-26-2022")!), 12)
        
        // Test not done in weeks
        XCTAssertEqual(habit.notDoneInWeeks(on: df.date(from: "12-7-2022")!),  nil)
        XCTAssertEqual(habit.notDoneInWeeks(on: df.date(from: "12-8-2022")!),  0)
        XCTAssertEqual(habit.notDoneInWeeks(on: df.date(from: "12-9-2022")!),  0)
        XCTAssertEqual(habit.notDoneInWeeks(on: df.date(from: "12-10-2022")!), 0)
        XCTAssertEqual(habit.notDoneInWeeks(on: df.date(from: "12-11-2022")!), 0)
        XCTAssertEqual(habit.notDoneInWeeks(on: df.date(from: "12-12-2022")!), 0)
        XCTAssertEqual(habit.notDoneInWeeks(on: df.date(from: "12-13-2022")!), 0)
        XCTAssertEqual(habit.notDoneInWeeks(on: df.date(from: "12-14-2022")!), 0)
        XCTAssertEqual(habit.notDoneInWeeks(on: df.date(from: "12-15-2022")!), 0)
        XCTAssertEqual(habit.notDoneInWeeks(on: df.date(from: "12-16-2022")!), 0)
        XCTAssertEqual(habit.notDoneInWeeks(on: df.date(from: "12-17-2022")!), 0)
        XCTAssertEqual(habit.notDoneInWeeks(on: df.date(from: "12-18-2022")!), 0)
        XCTAssertEqual(habit.notDoneInWeeks(on: df.date(from: "12-19-2022")!), 0)
        XCTAssertEqual(habit.notDoneInWeeks(on: df.date(from: "12-20-2022")!), 0)
        XCTAssertEqual(habit.notDoneInWeeks(on: df.date(from: "12-21-2022")!), 0)
        XCTAssertEqual(habit.notDoneInWeeks(on: df.date(from: "12-22-2022")!), 0)
        XCTAssertEqual(habit.notDoneInWeeks(on: df.date(from: "12-23-2022")!), 0)
        XCTAssertEqual(habit.notDoneInWeeks(on: df.date(from: "12-24-2022")!), 0)
        XCTAssertEqual(habit.notDoneInWeeks(on: df.date(from: "12-25-2022")!), 1)
        XCTAssertEqual(habit.notDoneInWeeks(on: df.date(from: "12-26-2022")!), 1)
    }
}
