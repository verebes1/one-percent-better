////
////  HabitsHeaderViewTests.swift
////  one-percent-better-swiftuiTests
////
////  Created by Jeremy Cook on 6/12/22.
////
//
//import XCTest
//@testable import One_Percent_Better
//
//class HabitsHeaderViewTests: XCTestCase {
//
//    let context = CoreDataManager.previews.mainContext
//
//    var hwvm: HeaderWeekViewModel!
//    var sdvm: SelectedDateViewModel!
//
//    var habit1: Habit!
//
//    override func setUpWithError() throws {
//        sdvm = SelectedDateViewModel()
//        hwvm = HeaderWeekViewModel(context, sdvm: sdvm)
//        habit1 = try! Habit(context: context, name: "Cook")
//    }
//
//    override func tearDownWithError() throws {
//        // Remove all habits before next test
//        let habits = Habit.habits(from: context)
//        habits.deleteAll(from: context)
//    }
//
//    /// Test the number of weeks since the earliest completed habit
//    func testNumWeeksSinceEarliestCompletedHabit() {
//        let today = Date()
//        Weekday.startOfWeek = Weekday(today)
//
//        habit1.updateStartDate(to: today)
//        XCTAssertEqual(hwvm.totalNumWeeks, 0)
//
//        var startDate = Cal.add(days: -1, to: today)
//        habit1.updateStartDate(to: startDate)
//        XCTAssertEqual(hwvm.totalNumWeeks, 1)
//
//        startDate = Cal.add(days: -7, to: today)
//        habit1.updateStartDate(to: startDate)
//        XCTAssertEqual(hwvm.totalNumWeeks, 1)
//
//        startDate = Cal.add(days: -8, to: today)
//        habit1.updateStartDate(to: startDate)
//        XCTAssertEqual(hwvm.totalNumWeeks, 2)
//
//        startDate = Cal.add(days: -14, to: today)
//        habit1.updateStartDate(to: startDate)
//        XCTAssertEqual(hwvm.totalNumWeeks, 2)
//
//        startDate = Cal.add(days: -15, to: today)
//        habit1.updateStartDate(to: startDate)
//        XCTAssertEqual(hwvm.totalNumWeeks, 3)
//    }
//
//    /// Test getting the week index given a particular day
//    func testWeekIndex() {
//        let today = Date()
//        Weekday.startOfWeek = Weekday(today)
//
//        habit1.updateStartDate(to: today)
//        XCTAssertEqual(hwvm.weekIndex(for: today), 0)
//
//        var startDate = Cal.add(days: -1, to: today)
//        habit1.updateStartDate(to: startDate)
//        XCTAssertEqual(hwvm.weekIndex(for: startDate), 0)
//        XCTAssertEqual(hwvm.weekIndex(for: today), 1)
//
//        startDate = Cal.add(days: -7, to: today)
//        habit1.updateStartDate(to: startDate)
//        XCTAssertEqual(hwvm.weekIndex(for: startDate), 0)
//        XCTAssertEqual(hwvm.weekIndex(for: today), 1)
//
//        startDate = Cal.add(days: -8, to: today)
//        habit1.updateStartDate(to: startDate)
//        XCTAssertEqual(hwvm.weekIndex(for: startDate), 0)
//        XCTAssertEqual(hwvm.weekIndex(for: today), 2)
//
//        startDate = Cal.add(days: -14, to: today)
//        habit1.updateStartDate(to: startDate)
//        XCTAssertEqual(hwvm.weekIndex(for: startDate), 0)
//        XCTAssertEqual(hwvm.weekIndex(for: today), 2)
//
//        startDate = Cal.add(days: -15, to: today)
//        habit1.updateStartDate(to: startDate)
//        XCTAssertEqual(hwvm.weekIndex(for: startDate), 0)
//        XCTAssertEqual(hwvm.weekIndex(for: today), 3)
//    }
//
//    /// Test getting the week index given a particular day
//    func testWeekIndex2() {
//        let today = Date()
//        Weekday.startOfWeek = Weekday(Cal.add(days: -1, to: today))
//
//        habit1.updateStartDate(to: today)
//        XCTAssertEqual(hwvm.weekIndex(for: today), 0)
//
//        var startDate = Cal.add(days: -1, to: today)
//        habit1.updateStartDate(to: startDate)
//        XCTAssertEqual(hwvm.weekIndex(for: startDate), 0)
//        XCTAssertEqual(hwvm.weekIndex(for: today), 0)
//
//        startDate = Cal.add(days: -2, to: today)
//        habit1.updateStartDate(to: startDate)
//        XCTAssertEqual(hwvm.weekIndex(for: startDate), 0)
//        XCTAssertEqual(hwvm.weekIndex(for: today), 1)
//
//        startDate = Cal.add(days: -8, to: today)
//        habit1.updateStartDate(to: startDate)
//        XCTAssertEqual(hwvm.weekIndex(for: startDate), 0)
//        XCTAssertEqual(hwvm.weekIndex(for: today), 1)
//
//        startDate = Cal.add(days: -9, to: today)
//        habit1.updateStartDate(to: startDate)
//        XCTAssertEqual(hwvm.weekIndex(for: startDate), 0)
//        XCTAssertEqual(hwvm.weekIndex(for: today), 2)
//
//        startDate = Cal.add(days: -15, to: today)
//        habit1.updateStartDate(to: startDate)
//        XCTAssertEqual(hwvm.weekIndex(for: startDate), 0)
//        XCTAssertEqual(hwvm.weekIndex(for: today), 2)
//
//        startDate = Cal.add(days: -16, to: today)
//        habit1.updateStartDate(to: startDate)
//        XCTAssertEqual(hwvm.weekIndex(for: startDate), 0)
//        XCTAssertEqual(hwvm.weekIndex(for: today), 3)
//    }
//}
