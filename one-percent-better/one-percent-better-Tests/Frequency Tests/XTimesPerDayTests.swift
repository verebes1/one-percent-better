//
//  XTimesPerDayTests.swift
//  one-percent-betterTests
//
//  Created by Jeremy Cook on 2/20/23.
//

import XCTest
@testable import One_Percent_Better

final class XTimesPerDayTests: XCTestCase {

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
   
   // MARK: Completed On Tests
   
   func testCompletedOn() {
      let startSunday = df.date(from: "01-29-2023")!
      habit.updateStartDate(to: startSunday)
      habit.updateFrequency(to: .timesPerDay(1), on: startSunday)
      
      XCTAssertFalse(habit.wasCompleted(on: startSunday))
      XCTAssertEqual(habit.percentCompleted(on: startSunday), 0)
      
      habit.markCompleted(on: startSunday)
      XCTAssertTrue(habit.wasCompleted(on: startSunday))
      XCTAssertEqual(habit.percentCompleted(on: startSunday), 1)
      
      XCTAssertFalse(habit.wasCompleted(on: Cal.add(days: 1, to: startSunday)))
      XCTAssertEqual(habit.percentCompleted(on: Cal.add(days: 1, to: startSunday)), 0)
      
      habit.markCompleted(on: Cal.add(days: 1, to: startSunday))
      XCTAssertTrue(habit.wasCompleted(on: Cal.add(days: 1, to: startSunday)))
      XCTAssertEqual(habit.percentCompleted(on: Cal.add(days: 1, to: startSunday)), 1)
   }
   
   func testCompletedOn2() {
      let startSunday = df.date(from: "01-29-2023")!
      habit.updateStartDate(to: startSunday)
      habit.updateFrequency(to: .timesPerDay(4), on: startSunday)
      
      XCTAssertFalse(habit.wasCompleted(on: startSunday))
      XCTAssertEqual(habit.percentCompleted(on: startSunday), 0)
      
      habit.markCompleted(on: startSunday)
      XCTAssertFalse(habit.wasCompleted(on: startSunday))
      XCTAssertEqual(habit.percentCompleted(on: startSunday), 0.25)
      
      habit.markCompleted(on: startSunday)
      XCTAssertFalse(habit.wasCompleted(on: startSunday))
      XCTAssertEqual(habit.percentCompleted(on: startSunday), 0.5)
      
      habit.markCompleted(on: startSunday)
      XCTAssertFalse(habit.wasCompleted(on: startSunday))
      XCTAssertEqual(habit.percentCompleted(on: startSunday), 0.75)
      
      habit.markCompleted(on: startSunday)
      XCTAssertTrue(habit.wasCompleted(on: startSunday))
      XCTAssertEqual(habit.percentCompleted(on: startSunday), 1.0)
   }
   
   // MARK: Is Due On Tests
   
   func testIsDueOn() {
      let startSunday = df.date(from: "01-29-2023")!
      habit.updateStartDate(to: startSunday)
      habit.updateFrequency(to: .timesPerDay(4), on: startSunday)
      
      XCTAssertTrue(habit.isDue(on: startSunday))
      XCTAssertTrue(habit.isDue(on: Cal.add(days: 1, to: startSunday)))
      XCTAssertTrue(habit.isDue(on: Cal.add(days: 2, to: startSunday)))
      XCTAssertTrue(habit.isDue(on: Cal.add(days: 3, to: startSunday)))
      XCTAssertTrue(habit.isDue(on: Cal.add(days: 4, to: startSunday)))
      XCTAssertTrue(habit.isDue(on: Cal.add(days: 5, to: startSunday)))
      XCTAssertTrue(habit.isDue(on: Cal.add(days: 6, to: startSunday)))
      XCTAssertTrue(habit.isDue(on: Cal.add(days: 7, to: startSunday)))
   }
   
   // MARK: Streak Tests
   
   func testStreak() {
      let startSunday = df.date(from: "01-29-2023")!
      habit.updateStartDate(to: startSunday)
      habit.updateFrequency(to: .timesPerDay(1), on: startSunday)
      
      XCTAssertEqual(habit.streak(on: startSunday), 0)
      
      habit.markCompleted(on: startSunday)
      XCTAssertEqual(habit.streak(on: startSunday), 1)
      XCTAssertEqual(habit.streak(on: Cal.add(days: 1, to: startSunday)), 1)
      XCTAssertEqual(habit.streak(on: Cal.add(days: 2, to: startSunday)), 0)
      
      habit.markCompleted(on: Cal.add(days: 1, to: startSunday))
      XCTAssertEqual(habit.streak(on: startSunday), 1)
      XCTAssertEqual(habit.streak(on: Cal.add(days: 1, to: startSunday)), 2)
      XCTAssertEqual(habit.streak(on: Cal.add(days: 2, to: startSunday)), 2)
      XCTAssertEqual(habit.streak(on: Cal.add(days: 3, to: startSunday)), 0)
   }
   
   func testStreak2() {
      let startSunday = df.date(from: "01-29-2023")!
      habit.updateStartDate(to: startSunday)
      habit.updateFrequency(to: .timesPerDay(2), on: startSunday)
      
      XCTAssertEqual(habit.streak(on: startSunday), 0)
      
      habit.markCompleted(on: startSunday)
      XCTAssertEqual(habit.streak(on: startSunday), 0)
      
      habit.markCompleted(on: startSunday)
      XCTAssertEqual(habit.streak(on: startSunday), 1)
      XCTAssertEqual(habit.streak(on: Cal.add(days: 1, to: startSunday)), 1)
      XCTAssertEqual(habit.streak(on: Cal.add(days: 2, to: startSunday)), 0)
   }
   
   // MARK: Improvement Score Tests
   
   func testImprovementScore() {
      let startDate = Cal.mostRecent(weekday: Weekday(Date()))
      habit.updateStartDate(to: startDate)
      habit.updateFrequency(to: .timesPerDay(2), on: startDate)
      
      // 0 for start date, and 0 for first week failed
      XCTAssertEqual(habit.improvementTracker!.scores, Array(repeating: 0, count: 8))
      
      habit.markCompleted(on: startDate)
      // [0.5, 0, 0, 0, 0, 0, 0, 0]
      XCTAssertEqual(habit.improvementTracker!.scores[0], 0.5, accuracy: 0.01)
      XCTAssertEqual(habit.improvementTracker!.scores[1], 0, accuracy: 0.01)
      
      habit.markCompleted(on: startDate)
      // [1.0, 0.5, 0, 0, 0, 0, 0, 0]
      XCTAssertEqual(habit.improvementTracker!.scores[0], 1.0, accuracy: 0.01)
      XCTAssertEqual(habit.improvementTracker!.scores[1], 0.5, accuracy: 0.01)
      XCTAssertEqual(habit.improvementTracker!.scores[2], 0, accuracy: 0.01)

      habit.markCompleted(on: Cal.add(days: 1, to: startDate))
      // [1.0, 1.5, 1.0, 0.5, 0, 0, 0, 0]
      XCTAssertEqual(habit.improvementTracker!.scores[1], 1.5, accuracy: 0.01)
      XCTAssertEqual(habit.improvementTracker!.scores[2], 1.0, accuracy: 0.01)
      XCTAssertEqual(habit.improvementTracker!.scores[3], 0.5, accuracy: 0.01)
      XCTAssertEqual(habit.improvementTracker!.scores[4], 0, accuracy: 0.01)
      
      habit.markCompleted(on: Cal.add(days: 2, to: startDate))
      // [1.0, 1.5, 2.01, 1.5, 1.0, 0.49, 0, 0]
      XCTAssertEqual(habit.improvementTracker!.scores[2], 2.01, accuracy: 0.01)
      XCTAssertEqual(habit.improvementTracker!.scores[3], 1.5, accuracy: 0.01)
      XCTAssertEqual(habit.improvementTracker!.scores[4], 1.0, accuracy: 0.01)
      XCTAssertEqual(habit.improvementTracker!.scores[5], 0.49, accuracy: 0.01)
      XCTAssertEqual(habit.improvementTracker!.scores[6], 0, accuracy: 0.01)
      
      habit.markCompleted(on: Cal.add(days: 2, to: startDate))
      // [1.0, 1.5, 2.52, 2.0, 1.5, 0.99, 0.48, 0]
      XCTAssertEqual(habit.improvementTracker!.scores[2], 2.52, accuracy: 0.01)
      XCTAssertEqual(habit.improvementTracker!.scores[3], 2.0, accuracy: 0.01)
      XCTAssertEqual(habit.improvementTracker!.scores[4], 1.5, accuracy: 0.01)
      XCTAssertEqual(habit.improvementTracker!.scores[5], 0.99, accuracy: 0.01)
      XCTAssertEqual(habit.improvementTracker!.scores[6], 0.49, accuracy: 0.01)
      XCTAssertEqual(habit.improvementTracker!.scores[7], 0, accuracy: 0.01)
   }
   
   func testEquality() {
      let startSunday = df.date(from: "01-29-2023")!
      habit.updateStartDate(to: startSunday)
      habit.updateFrequency(to: .timesPerDay(1), on: startSunday)
      
      XCTAssertEqual(habit.frequenciesArray.count, 1)
   }
}
