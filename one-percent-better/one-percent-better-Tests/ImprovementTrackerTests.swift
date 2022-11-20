//
//  ImprovementTrackerTests.swift
//  one-percent-betterTests
//
//  Created by Jeremy Cook on 11/10/22.
//

import XCTest
@testable import ___Better

final class ImprovementTrackerTests: XCTestCase {
   
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
   
   func testOneDay() throws {
      let today = Date()
      
      habit.markCompleted(on: today)
      XCTAssertEqual(["0", "1"], habit.improvementTracker?.values)
      
      habit.markNotCompleted(on: today)
      XCTAssertEqual(["0", "0"], habit.improvementTracker?.values)
   }
   
   func testTwoDays() throws {
      let today = Date()
      let yesterday = Cal.date(byAdding: .day, value: -1, to: today)!
      
      habit.markCompleted(on: yesterday)
      XCTAssertEqual(["0", "1", "0"], habit.improvementTracker?.values)
      habit.markCompleted(on: today)
      XCTAssertEqual(["0", "1", "2"], habit.improvementTracker?.values)
   }
   
   func testThreeDays() throws {
      let d2 = Date()
      let d1 = Cal.date(byAdding: .day, value: -1, to: d2)!
      let d0 = Cal.date(byAdding: .day, value: -2, to: d2)!
      
      habit.startDate = d0
      habit.improvementTracker?.update(on: Date())
      XCTAssertEqual(["0", "0", "0", "0"], habit.improvementTracker?.values)
      
      habit.markCompleted(on: d0)
      XCTAssertEqual(["0", "1", "0", "0"], habit.improvementTracker?.values)
      
      habit.markNotCompleted(on: d0)
      habit.markCompleted(on: d1)
      XCTAssertEqual(["0", "0", "1", "0"], habit.improvementTracker?.values)
      
      habit.markNotCompleted(on: d1)
      habit.markCompleted(on: d2)
      XCTAssertEqual(["0", "0", "0", "1"], habit.improvementTracker?.values)
      
      habit.markCompleted(on: d1)
      XCTAssertEqual(["0", "0", "1", "2"], habit.improvementTracker?.values)
      
      habit.markCompleted(on: d0)
      XCTAssertEqual(["0", "1", "2", "3"], habit.improvementTracker?.values)
      
      habit.markNotCompleted(on: d1)
      XCTAssertEqual(["0", "1", "0", "1"], habit.improvementTracker?.values)
   }
   
   func testCompletionDayBeforeStartDay() throws {
      let d1 = Date()
      let d0 = Cal.date(byAdding: .day, value: -1, to: d1)!
      let dn1 = Cal.date(byAdding: .day, value: -2, to: d1)!
      
      habit.startDate = d0
      habit.improvementTracker?.update(on: Date())
      XCTAssertEqual(["0", "0", "0"], habit.improvementTracker?.values)
      
      habit.markCompleted(on: dn1)
      XCTAssertEqual(["0", "1", "0", "0"], habit.improvementTracker?.values)
   }
   
   func testTimesPerDayFrequency() throws {
      habit.startDate = Cal.dayBefore(byAddingDays: -1)
      habit.changeFrequency(to: .timesPerDay(2), on: habit.startDate)
      
      habit.markCompleted(on: Cal.dayBefore(byAddingDays: -1))
      XCTAssertEqual(["0", "0", "0"], habit.improvementTracker?.values)
      habit.markCompleted(on: Cal.dayBefore(byAddingDays: -1))
      XCTAssertEqual(["0", "1", "0"], habit.improvementTracker?.values)
      habit.markCompleted(on: Cal.dayBefore(byAddingDays: 0))
      // 0, 1, 1.501
      XCTAssertEqual(["0", "1", "2"], habit.improvementTracker?.values)
   }
   
   func testSMTWTFSFrequency() throws {
      habit.startDate = Cal.dayBefore(byAddingDays: -2)
      let yesterday = Cal.dayBefore(byAddingDays: -1).weekdayInt
      habit.changeFrequency(to: .daysInTheWeek([yesterday]), on: habit.startDate)
      
      habit.markCompleted(on: Cal.dayBefore(byAddingDays: -2))
      // -3 -2 -1  0
      //  0  1  0  -
      XCTAssertEqual(["0", "1", "0"], habit.improvementTracker?.values)
      
      habit.markNotCompleted(on: Cal.dayBefore(byAddingDays: -2))
      // -3 -2 -1  0
      //  0  -  0  -
      XCTAssertEqual(["0", "0"], habit.improvementTracker?.values)
      
      // -3 -2 -1  0
      //  0  -  1  -
      habit.markCompleted(on: Cal.dayBefore(byAddingDays: -1))
      XCTAssertEqual(["0", "1"], habit.improvementTracker?.values)
      
      // -3 -2 -1  0
      //  0  -  1  2
      habit.markCompleted(on: Cal.dayBefore(byAddingDays: 0))
      XCTAssertEqual(["0", "1", "2"], habit.improvementTracker?.values)
   }
   
   func testSMTWTFSFrequency2() throws {
      habit.startDate = Cal.dayBefore(byAddingDays: -2)
      let yesterday = Cal.dayBefore(byAddingDays: -1).weekdayInt
      habit.changeFrequency(to: .daysInTheWeek([yesterday]), on: habit.startDate)
      
      habit.markCompleted(on: Cal.dayBefore(byAddingDays: -2))
      // -3 -2 -1  0
      //  0  1  0  -
      XCTAssertEqual(["0", "1", "0"], habit.improvementTracker?.values)
   }
}
