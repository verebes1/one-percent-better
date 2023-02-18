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
   
   /// Test if `wasCompletedThisWeek` works.
   /// Test that you can ask for any day of the week and get the same answer
   func testCompletedOn2() {
      let startSunday = df.date(from: "01-29-2023")!
      habit.updateStartDate(to: startSunday)
      habit.changeFrequency(to: .timesPerWeek(times: 3, resetDay: .sunday), on: startSunday)
      
      for i in 0 ..< 7 {
         XCTAssertFalse(habit.wasCompletedThisWeek(on: Cal.addDays(num: i, to: startSunday)))
      }
      habit.markCompleted(on: startSunday)
      for i in 0 ..< 7 {
         XCTAssertFalse(habit.wasCompletedThisWeek(on: Cal.addDays(num: i, to: startSunday)))
      }
      habit.markCompleted(on: Cal.addDays(num: 1, to: startSunday))
      for i in 0 ..< 7 {
         XCTAssertFalse(habit.wasCompletedThisWeek(on: Cal.addDays(num: i, to: startSunday)))
      }
      habit.markCompleted(on: Cal.addDays(num: 2, to: startSunday))
      for i in 0 ..< 7 {
         XCTAssertTrue(habit.wasCompletedThisWeek(on: Cal.addDays(num: i, to: startSunday)))
      }
   }
   
   /// Test `wasCompletedThisWeek` works if your start date is tuesday, and you reset every monday, and you complete it your first week
   func testCompletedOn3() {
      let startTuesday = df.date(from: "12-6-2022")!
      habit.updateStartDate(to: startTuesday)
      habit.changeFrequency(to: .timesPerWeek(times: 3, resetDay: .monday), on: startTuesday)
      
      XCTAssertFalse(habit.wasCompletedThisWeek(on: startTuesday))
      habit.markCompleted(on: startTuesday)
      habit.markCompleted(on: Cal.addDays(num: 1, to: startTuesday))
      habit.markCompleted(on: Cal.addDays(num: 2, to: startTuesday))
      XCTAssertTrue(habit.wasCompletedThisWeek(on: startTuesday))
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
   
   func testStreak() {
      let startWednesday = df.date(from: "12-7-2022")!
      habit.updateStartDate(to: startWednesday)
      habit.changeFrequency(to: .timesPerWeek(times: 1, resetDay: .tuesday), on: startWednesday)
      
      XCTAssertEqual(habit.streak(on: startWednesday), 0)
      habit.markCompleted(on: startWednesday)
      XCTAssertEqual(habit.streak(on: startWednesday), 1)
      habit.markCompleted(on: Cal.addDays(num: 7, to: startWednesday))
      XCTAssertEqual(habit.streak(on: Cal.addDays(num: 7, to: startWednesday)), 2)
      XCTAssertEqual(habit.streak(on: Cal.addDays(num: 8, to: startWednesday)), 2)
      XCTAssertEqual(habit.streak(on: Cal.addDays(num: 9, to: startWednesday)), 2)
      XCTAssertEqual(habit.streak(on: Cal.addDays(num: 10, to: startWednesday)), 2)
      XCTAssertEqual(habit.streak(on: Cal.addDays(num: 11, to: startWednesday)), 2)
      XCTAssertEqual(habit.streak(on: Cal.addDays(num: 12, to: startWednesday)), 2)
      XCTAssertEqual(habit.streak(on: Cal.addDays(num: 13, to: startWednesday)), 2)
      XCTAssertEqual(habit.streak(on: Cal.addDays(num: 14, to: startWednesday)), 0)
   }
   
   func testStreak2() {
      let startWednesday = df.date(from: "12-7-2022")!
      habit.updateStartDate(to: startWednesday)
      habit.changeFrequency(to: .timesPerWeek(times: 2, resetDay: .saturday), on: startWednesday)
      
      XCTAssertEqual(habit.streak(on: startWednesday), 0)
      habit.markCompleted(on: startWednesday)
      XCTAssertEqual(habit.streak(on: startWednesday), 0)
      habit.markCompleted(on: Cal.addDays(num: 1, to: startWednesday))
      XCTAssertEqual(habit.streak(on: Cal.addDays(num: 1, to: startWednesday)), 1)
   }
   
   func testStreak3() {
      let startWednesday = df.date(from: "12-7-2022")!
      habit.updateStartDate(to: startWednesday)
      habit.changeFrequency(to: .timesPerWeek(times: 2, resetDay: .thursday), on: startWednesday)
      
      XCTAssertEqual(habit.streak(on: startWednesday), 0)
      habit.markCompleted(on: startWednesday)
      XCTAssertEqual(habit.streak(on: startWednesday), 0)
      habit.markCompleted(on: Cal.addDays(num: 1, to: startWednesday))
      XCTAssertEqual(habit.streak(on: Cal.addDays(num: 1, to: startWednesday)), 1)
      habit.markCompleted(on: Cal.addDays(num: 2, to: startWednesday))
      XCTAssertEqual(habit.streak(on: Cal.addDays(num: 1, to: startWednesday)), 1)
   }
   
   func testImprovementScore() {
      let today = Date().weekdayInt
      let startDate = Cal.getLast(weekday: Weekday(rawValue: today)!)
      habit.updateStartDate(to: startDate)
      habit.changeFrequency(to: .timesPerWeek(times: 3, resetDay: .sunday), on: startDate)
      
      XCTAssertEqual(habit.improvementTracker!.values, ["0"])
      XCTAssertEqual(habit.improvementTracker!.scores, [0])
      
      habit.markCompleted(on: startDate)
      XCTAssertEqual(habit.improvementTracker!.values, ["0"])
      XCTAssertEqual(habit.improvementTracker!.scores[0], 0.33, accuracy: 0.01)
      
      habit.markCompleted(on: Cal.addDays(num: 1, to: startDate))
      XCTAssertEqual(habit.improvementTracker!.values, ["0", "1"])
      XCTAssertEqual(habit.improvementTracker!.scores[1], 0.66, accuracy: 0.01)
      
      habit.markCompleted(on: Cal.addDays(num: 2, to: startDate))
      XCTAssertEqual(habit.improvementTracker!.values, ["0", "1", "1"])
      XCTAssertEqual(habit.improvementTracker!.scores[2], 1.0, accuracy: 0.01)
   }
   
}
