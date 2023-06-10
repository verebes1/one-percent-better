//
//  FrequencyTests.swift
//  one-percent-betterTests
//
//  Created by Jeremy Cook on 11/28/22.
//

import XCTest
@testable import One_Percent_Better

final class FrequencyTests: XCTestCase {

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
      XCTAssertEqual(habit.frequenciesArray.first!.startDate, today)
      
      let threeDaysAgo = Cal.add(days: -3)
      habit.updateStartDate(to: threeDaysAgo)
      XCTAssertEqual(habit.startDate, threeDaysAgo.startOfDay())
      XCTAssertEqual(habit.frequenciesArray.first!.startDate, threeDaysAgo.startOfDay())
   }
   
   func testFrequencyBeforeAllFrequencyDates() throws {
      let threeDaysAgo = Cal.add(days: -3)
      XCTAssertNil(habit.frequency(on: threeDaysAgo))
   }

}
