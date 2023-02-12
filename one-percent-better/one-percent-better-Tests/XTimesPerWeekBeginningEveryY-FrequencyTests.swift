//
//  XTimesPerWeekBeginningEveryY-FrequencyTests.swift
//  one-percent-betterTests
//
//  Created by Jeremy Cook on 2/7/23.
//

import XCTest
@testable import ___Better

final class XTimesPerWeekBeginningEveryY_FrequencyTests: XCTestCase {
   
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
   
   func testCompletedOn() {
      let startSunday = df.date(from: "01-29-2023")!
      habit.updateStartDate(to: startSunday)
      habit.changeFrequency(to: .timesPerWeek(times: 3, resetDay: .sunday), on: startSunday)
      
      XCTAssertFalse(habit.wasCompleted(on: startSunday))
      XCTAssertEqual(habit.percentCompleted(on: startSunday), 0)
      
      habit.markCompleted(on: startSunday)
      XCTAssertTrue(habit.wasCompleted(on: startSunday))
      XCTAssertEqual(habit.percentCompleted(on: startSunday), 1)
   }
   
   /// Test that the habit is only due on the reset day
   func testIsDue() {
      let startSunday = df.date(from: "1-29-2023")!
      habit.updateStartDate(to: startSunday)
      habit.changeFrequency(to: .timesPerWeek(times: 3, resetDay: .sunday), on: startSunday)
      
      XCTAssertTrue(habit.isDue(on: startSunday))
      
      for i in 1 ..< 7 {
         let day = Cal.addDays(num: i, to: startSunday)
         XCTAssertFalse(habit.isDue(on: day))
      }
         
      let nextSunday = Cal.addDays(num: 7, to: startSunday)
      XCTAssertTrue(habit.isDue(on: nextSunday))
   }
   
//   func testImprovementScore() {
//      let startSunday = df.date(from: "1-29-2023")!
//      habit.updateStartDate(to: startSunday)
//      habit.changeFrequency(to: .timesPerWeek(times: 3, resetDay: .sunday), on: startSunday)
//      
//      XCTAssertEqual(habit.improvementTracker!.values, ["0"])
//   }
   
   // TODO: 1.0.8 test case where start date is past reset day. I.e. start date is Wednesday 2-1-2023, reset day is sunday (1-29 or 2-5). Should habit still be marked as not completed if they didn't do it that week? I guess so
}
