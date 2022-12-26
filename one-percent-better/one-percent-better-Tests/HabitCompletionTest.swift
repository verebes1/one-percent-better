//
//  HabitCompletionTest.swift
//  one-percent-betterTests
//
//  Created by Jeremy Cook on 12/22/22.
//

import XCTest
@testable import ___Better

final class HabitCompletionTest: XCTestCase {
   
   let context = CoreDataManager.previews.mainContext

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testHabitCompletedYesterday() throws {
       let habit = try? Habit(context: context, name: "Basketball", frequency: .timesPerDay(1))
       let yesterday = Cal.addDays(num: -1)
       habit?.markCompleted(on: Cal.addDays(num: -2))
       XCTAssertNotNil(habit?.wasCompleted(on: yesterday))
       XCTAssertTrue(habit!.wasCompleted(on: yesterday))
    }

}
