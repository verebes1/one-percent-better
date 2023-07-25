//
//  DueOnTests.swift
//  one-percent-betterTests
//
//  Created by Jeremy Cook on 7/24/23.
//

import XCTest
@testable import One_Percent_Better

final class DueOnTests: XCTestCase {
   
   let context = CoreDataManager.previews.mainContext
   
   var habit: Habit!
   
   var df: DateFormatter = {
      let df = DateFormatter()
      df.dateFormat = "MM-dd-yyyy"
      return df
   }()
   
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
   
   func testXTimesPerDay() throws {
      let startDate = df.date(from: "7-20-2023")!
      habit.changeFrequency(to: .timesPerDay(1), on: startDate)
      XCTAssertTrue(habit.isDue(on: startDate))
      XCTAssertTrue(habit.isDue(on: Date()))
   }
}
