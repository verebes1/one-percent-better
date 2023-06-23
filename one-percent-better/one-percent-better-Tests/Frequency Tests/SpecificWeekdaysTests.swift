//
//  SpecificWeekdaysTests.swift
//  one-percent-betterTests
//
//  Created by Jeremy Cook on 2/21/23.
//

import XCTest
@testable import ___Better

final class SpecificWeekdaysTests: XCTestCase {

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
      habit.changeFrequency(to: .specificWeekdays([.monday, .wednesday, .friday]), on: startSunday)
      
      XCTAssertFalse(habit.wasCompleted(on: startSunday))
      XCTAssertEqual(habit.percentCompleted(on: startSunday), 0)
      
      habit.markCompleted(on: startSunday)
      XCTAssertTrue(habit.wasCompleted(on: startSunday))
      XCTAssertEqual(habit.percentCompleted(on: startSunday), 1.0)
      
      habit.markCompleted(on: Cal.add(days: 1, to: startSunday))
      XCTAssertTrue(habit.wasCompleted(on: Cal.add(days: 1, to: startSunday)))
      XCTAssertEqual(habit.percentCompleted(on: Cal.add(days: 1, to: startSunday)), 1.0)
      
      XCTAssertFalse(habit.wasCompleted(on: Cal.add(days: 2, to: startSunday)))
      XCTAssertEqual(habit.percentCompleted(on: Cal.add(days: 2, to: startSunday)), 0.0)
   }
   
   // MARK: Is Due On Tests
   
   /// Test that the habit is only due on the reset day
   func testIsDue() {
      let startSunday = df.date(from: "1-29-2023")!
      habit.updateStartDate(to: startSunday)
      habit.changeFrequency(to: .specificWeekdays([.monday, .tuesday, .wednesday]), on: startSunday)
      
      XCTAssertFalse(habit.isDue(on: startSunday))
      XCTAssertTrue(habit.isDue(on: Cal.add(days: 1, to: startSunday)))
      XCTAssertTrue(habit.isDue(on: Cal.add(days: 2, to: startSunday)))
      XCTAssertTrue(habit.isDue(on: Cal.add(days: 3, to: startSunday)))
      XCTAssertFalse(habit.isDue(on: Cal.add(days: 4, to: startSunday)))
      XCTAssertFalse(habit.isDue(on: Cal.add(days: 5, to: startSunday)))
      XCTAssertFalse(habit.isDue(on: Cal.add(days: 6, to: startSunday)))
      XCTAssertFalse(habit.isDue(on: Cal.add(days: 7, to: startSunday)))
      XCTAssertTrue(habit.isDue(on: Cal.add(days: 8, to: startSunday)))
   }
   
   func testIsDue2() {
      let startSunday = df.date(from: "1-29-2023")!
      habit.updateStartDate(to: startSunday)
      habit.changeFrequency(to: .specificWeekdays([.sunday, .friday, .saturday]), on: startSunday)
      
      XCTAssertTrue(habit.isDue(on: startSunday))
      XCTAssertFalse(habit.isDue(on: Cal.add(days: 1, to: startSunday)))
      XCTAssertFalse(habit.isDue(on: Cal.add(days: 2, to: startSunday)))
      XCTAssertFalse(habit.isDue(on: Cal.add(days: 3, to: startSunday)))
      XCTAssertFalse(habit.isDue(on: Cal.add(days: 4, to: startSunday)))
      XCTAssertTrue(habit.isDue(on: Cal.add(days: 5, to: startSunday)))
      XCTAssertTrue(habit.isDue(on: Cal.add(days: 6, to: startSunday)))
      XCTAssertTrue(habit.isDue(on: Cal.add(days: 7, to: startSunday)))
      XCTAssertFalse(habit.isDue(on: Cal.add(days: 8, to: startSunday)))
   }
   
   // MARK: Improvement Score Tests
   
   func testImprovementScore() {
      let today = Date().weekdayInt
      let startDate = Cal.getLast(weekday: Weekday(today))
      habit.updateStartDate(to: startDate)
      let specificWeekdays = [Weekday(Cal.add(days: 1, to: Date()))]
      habit.changeFrequency(to: .specificWeekdays(specificWeekdays), on: startDate)
      
      // 0 for start date, and 0 for first time failed
      XCTAssertEqual(habit.improvementTracker!.scores, [0, 0])
      
      habit.markCompleted(on: startDate)
      XCTAssertEqual(habit.improvementTracker!.scores[0], 1, accuracy: 0.01)
      
      habit.markCompleted(on: Cal.add(days: 1, to: startDate))
      XCTAssertEqual(habit.improvementTracker!.scores[1], 2.01, accuracy: 0.01)
      
      habit.markCompleted(on: Cal.add(days: 2, to: startDate))
      XCTAssertEqual(habit.improvementTracker!.scores[2], 3.03, accuracy: 0.01)
   }
   
   func testImprovementScore2() {
      let today = Date().weekdayInt
      let startDate = Cal.getLast(weekday: Weekday(today))
      habit.updateStartDate(to: startDate)
      let specificWeekdays = [Weekday(Cal.add(days: 1, to: Date())), Weekday(Cal.add(days: 3, to: Date()))]
      habit.changeFrequency(to: .specificWeekdays(specificWeekdays), on: startDate)
      
      // 0 for start, and two more 0s for next two failed
      XCTAssertEqual(habit.improvementTracker!.scores, [0, 0, 0])
      
      habit.markCompleted(on: Cal.add(days: 1, to: startDate))
      XCTAssertEqual(habit.improvementTracker!.scores[0], 0)
      XCTAssertEqual(habit.improvementTracker!.scores[1], 1)
      XCTAssertEqual(habit.improvementTracker!.scores[2], 0.49, accuracy: 0.01)
      
      habit.markCompleted(on: Cal.add(days: 2, to: startDate))
      // [0.0, 1.0, 2.01, 1.49]
      XCTAssertEqual(habit.improvementTracker!.scores[0], 0)
      XCTAssertEqual(habit.improvementTracker!.scores[1], 1)
      XCTAssertEqual(habit.improvementTracker!.scores[2], 2.01, accuracy: 0.01)
      XCTAssertEqual(habit.improvementTracker!.scores[3], 1.49, accuracy: 0.01)
      
      habit.markCompleted(on: Cal.add(days: 3, to: startDate))
      // [0.0, 1.0, 2.01, 3.03]
      XCTAssertEqual(habit.improvementTracker!.scores[0], 0)
      XCTAssertEqual(habit.improvementTracker!.scores[1], 1)
      XCTAssertEqual(habit.improvementTracker!.scores[2], 2.01, accuracy: 0.01)
      XCTAssertEqual(habit.improvementTracker!.scores[3], 3.03, accuracy: 0.01)
      XCTAssertEqual(habit.percentCompleted(on: Cal.add(days: 3, to: startDate)), 1.0)
      
      habit.markCompleted(on: Cal.add(days: 5, to: startDate))
      // [0.0, 1.0, 2.01, 3.03, 4.06]
      XCTAssertEqual(habit.improvementTracker!.scores[0], 0)
      XCTAssertEqual(habit.improvementTracker!.scores[1], 1)
      XCTAssertEqual(habit.improvementTracker!.scores[2], 2.01, accuracy: 0.01)
      XCTAssertEqual(habit.improvementTracker!.scores[3], 3.03, accuracy: 0.01)
      XCTAssertEqual(habit.improvementTracker!.scores[4], 4.06, accuracy: 0.01)
      
      habit.markCompleted(on: Cal.add(days: 6, to: startDate))
      // [0.0, 1.0, 2.01, 3.03, 4.96]
      XCTAssertEqual(habit.improvementTracker!.scores[0], 0)
      XCTAssertEqual(habit.improvementTracker!.scores[1], 1)
      XCTAssertEqual(habit.improvementTracker!.scores[2], 2.01, accuracy: 0.01)
      XCTAssertEqual(habit.improvementTracker!.scores[3], 3.03, accuracy: 0.01)
      XCTAssertEqual(habit.improvementTracker!.scores[4], 4.06, accuracy: 0.01)
      XCTAssertEqual(habit.improvementTracker!.scores[5], 5.10, accuracy: 0.01)
   }

}
