//
//  HabitsHeaderViewTests.swift
//  one-percent-better-swiftuiTests
//
//  Created by Jeremy Cook on 6/12/22.
//

import XCTest
@testable import One_Percent_Better

class HabitsHeaderViewTests: XCTestCase {
    
    let context = CoreDataManager.previews.mainContext
    
    var hwvm: HeaderWeekViewModel!
    var hsvm: HeaderSelectionViewModel!
    
    var habit1: Habit!

    override func setUpWithError() throws {
        hwvm = HeaderWeekViewModel(context)
        hsvm = HeaderSelectionViewModel(hwvm: hwvm)
        habit1 = try! Habit(context: context, name: "Cook")
    }

    override func tearDownWithError() throws {
        // Remove all habits before next test
        let habits = Habit.habits(from: context)
        habits.deleteAll(from: context)
    }
    
    /// Test the number of weeks since the earliest completed habit
    func testNumWeeksSinceEarliestCompletedHabit() {
        let today = Date()
        Weekday.startOfWeek = Weekday(today)
        
        habit1.updateStartDate(to: today)
        XCTAssertEqual(hwvm.numWeeksSinceEarliestCompletedHabit, 0)
        
        var startDate = Cal.add(days: -1, to: today)
        habit1.updateStartDate(to: startDate)
        XCTAssertEqual(hwvm.numWeeksSinceEarliestCompletedHabit, 1)
        
        startDate = Cal.add(days: -7, to: today)
        habit1.updateStartDate(to: startDate)
        XCTAssertEqual(hwvm.numWeeksSinceEarliestCompletedHabit, 1)
        
        startDate = Cal.add(days: -8, to: today)
        habit1.updateStartDate(to: startDate)
        XCTAssertEqual(hwvm.numWeeksSinceEarliestCompletedHabit, 2)
        
        startDate = Cal.add(days: -14, to: today)
        habit1.updateStartDate(to: startDate)
        XCTAssertEqual(hwvm.numWeeksSinceEarliestCompletedHabit, 2)
        
        startDate = Cal.add(days: -15, to: today)
        habit1.updateStartDate(to: startDate)
        XCTAssertEqual(hwvm.numWeeksSinceEarliestCompletedHabit, 3)
    }
    
    func testDayOffset() {
        
    }
}
