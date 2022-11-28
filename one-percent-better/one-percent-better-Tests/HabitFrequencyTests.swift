//
//  HabitFrequencyTests.swift
//  one-percent-betterTests
//
//  Created by Jeremy Cook on 11/28/22.
//

import XCTest
@testable import ___Better

final class HabitFrequencyTests: XCTestCase {

   let context = CoreDataManager.previews.mainContext
   
   var habit: Habit!
   
   override func setUpWithError() throws {
      // Put setup code here. This method is called before the invocation of each test method in the class.
      
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
   
   func testChangeStartDate() throws {
      let today = Date().startOfDay()
      
      XCTAssertEqual(habit.startDate, today)
      XCTAssertEqual(habit.frequencyDates[0].startOfDay(), today)
      
      let threeDaysAgo = Cal.addDays(num: -3)
      habit.updateStartDate(to: threeDaysAgo)
      XCTAssertEqual(habit.startDate, threeDaysAgo.startOfDay())
      XCTAssertEqual(habit.frequencyDates[0].startOfDay(), threeDaysAgo.startOfDay())
   }
   
   func testFrequencyBeforeAllFrequencyDates() throws {
      let threeDaysAgo = Cal.addDays(num: -3)
      XCTAssertNil(habit.frequency(on: threeDaysAgo))
   }

}
