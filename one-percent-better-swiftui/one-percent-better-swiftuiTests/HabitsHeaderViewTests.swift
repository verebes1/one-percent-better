//
//  HabitsHeaderViewTests.swift
//  one-percent-better-swiftuiTests
//
//  Created by Jeremy Cook on 6/12/22.
//

import XCTest
@testable import one_percent_better_swiftui

class HabitsHeaderViewTests: XCTestCase {
    
    let context = CoreDataManager.previews.persistentContainer.viewContext
    
    var formatter: DateFormatter = {
        let _formatter = DateFormatter()
        _formatter.dateFormat = "MM/dd/yyyy"
        return _formatter
    }()
    
    var sunday: Date!
    var monday: Date!
    var tuesday: Date!
    var wednesday: Date!
    var thursday: Date!
    var friday: Date!
    var saturday: Date!
    var nextSunday: Date!

    override func setUpWithError() throws {
        // This method is called before the invocation of each test method in the class.
        sunday = { formatter.date(from: "05/01/2022")! }()
        monday = formatter.date(from: "05/02/2022")!
        tuesday = formatter.date(from: "05/03/2022")!
        wednesday = formatter.date(from: "05/04/2022")!
        thursday = formatter.date(from: "05/05/2022")!
        friday = formatter.date(from: "05/06/2022")!
        saturday = formatter.date(from: "05/07/2022")!
        nextSunday = formatter.date(from: "05/08/2022")!
    }

    override func tearDownWithError() throws {
        // Remove all habits before next test
        let habits = Habit.habitList(from: context)
        for habit in habits {
            context.delete(habit)
            try? context.save()
        }
    }
    
    func testNumWeeksSunday() {
        let h1 = try! Habit(context: context, name: "Cook")
        h1.markCompleted(on: sunday)
        let vm = HabitsHeaderViewModel(habits: [h1], today: monday)
        XCTAssertEqual(vm.numWeeksSinceEarliest, 1)
    }
    
    func testNumWeeksMonday() {
        let h1 = try! Habit(context: context, name: "Cook")
        h1.markCompleted(on: monday)
        let vm = HabitsHeaderViewModel(habits: [h1], today: tuesday)
        XCTAssertEqual(vm.numWeeksSinceEarliest, 1)
    }
    
    func testNumWeeksTuesday() {
        let h1 = try! Habit(context: context, name: "Cook")
        h1.markCompleted(on: tuesday)
        let vm = HabitsHeaderViewModel(habits: [h1], today: wednesday)
        XCTAssertEqual(vm.numWeeksSinceEarliest, 1)
    }
    
    func testNumWeeksWednesday() {
        let h1 = try! Habit(context: context, name: "Cook")
        h1.markCompleted(on: wednesday)
        let vm = HabitsHeaderViewModel(habits: [h1], today: thursday)
        XCTAssertEqual(vm.numWeeksSinceEarliest, 1)
    }
    
    func testNumWeeksThursday() {
        let h1 = try! Habit(context: context, name: "Cook")
        h1.markCompleted(on: thursday)
        let vm = HabitsHeaderViewModel(habits: [h1], today: friday)
        XCTAssertEqual(vm.numWeeksSinceEarliest, 1)
    }
    
    func testNumWeeksFriday() {
        let h1 = try! Habit(context: context, name: "Cook")
        h1.markCompleted(on: friday)
        let vm = HabitsHeaderViewModel(habits: [h1], today: saturday)
        XCTAssertEqual(vm.numWeeksSinceEarliest, 1)
    }
    
    func testNumWeeksSaturday() {
        let h1 = try! Habit(context: context, name: "Cook")
        h1.markCompleted(on: saturday)
        let vm = HabitsHeaderViewModel(habits: [h1], today: nextSunday)
        XCTAssertEqual(vm.numWeeksSinceEarliest, 2)
    }
    
    func test7DayDiff() {
        let h1 = try! Habit(context: context, name: "Cook")
        h1.markCompleted(on: sunday)
        let vm = HabitsHeaderViewModel(habits: [h1], today: nextSunday)
        XCTAssertEqual(vm.numWeeksSinceEarliest, 2)
    }

}
