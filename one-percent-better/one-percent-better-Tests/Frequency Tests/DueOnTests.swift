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
      habit.updateStartDate(to: startDate)
      habit.updateFrequency(to: .timesPerDay(1), on: startDate)
      XCTAssertTrue(habit.isDue(on: startDate))
      XCTAssertTrue(habit.isDue(on: Cal.add(days: 1, to: startDate)))
      XCTAssertTrue(habit.isDue(on: Date()))
      
      habit.updateFrequency(to: .timesPerDay(3), on: startDate)
      XCTAssertTrue(habit.isDue(on: startDate))
      XCTAssertTrue(habit.isDue(on: Cal.add(days: 1, to: startDate)))
      XCTAssertTrue(habit.isDue(on: Date()))
   }
   
   func testSpecificWeekdays() throws {
      let startDate = df.date(from: "7-17-2023")! // a monday
      habit.updateStartDate(to: startDate)
      habit.updateFrequency(to: .specificWeekdays([.monday, .wednesday]), on: startDate)
      
      XCTAssertEqual(startDate.weekdayIndex, Weekday.monday.rawValue)
      
      XCTAssertTrue(habit.isDue(on: startDate)) // monday
      XCTAssertFalse(habit.isDue(on: Cal.add(days: 1, to: startDate))) // tuesday
      XCTAssertTrue(habit.isDue(on: Cal.add(days: 2, to: startDate))) // wednesday
      XCTAssertFalse(habit.isDue(on: Cal.add(days: 3, to: startDate))) // thursday
      XCTAssertFalse(habit.isDue(on: Cal.add(days: 4, to: startDate))) // friday
      XCTAssertFalse(habit.isDue(on: Cal.add(days: 5, to: startDate))) // saturday
      XCTAssertFalse(habit.isDue(on: Cal.add(days: 6, to: startDate))) // sunday
   }
   
   func testSpecificWeekdays2() throws {
      let startDate = df.date(from: "7-17-2023")! // a monday
      habit.updateStartDate(to: startDate)
      habit.updateFrequency(to: .specificWeekdays([.friday, .saturday, .sunday]), on: startDate)
      
      XCTAssertEqual(startDate.weekdayIndex, Weekday.monday.rawValue)
      
      XCTAssertFalse(habit.isDue(on: startDate)) // monday
      XCTAssertFalse(habit.isDue(on: Cal.add(days: 1, to: startDate))) // tuesday
      XCTAssertFalse(habit.isDue(on: Cal.add(days: 2, to: startDate))) // wednesday
      XCTAssertFalse(habit.isDue(on: Cal.add(days: 3, to: startDate))) // thursday
      XCTAssertTrue(habit.isDue(on: Cal.add(days: 4, to: startDate))) // friday
      XCTAssertTrue(habit.isDue(on: Cal.add(days: 5, to: startDate))) // saturday
      XCTAssertTrue(habit.isDue(on: Cal.add(days: 6, to: startDate))) // sunday
   }
   
   func testXTimesPerWeek() throws {
      let startDate = df.date(from: "7-17-2023")! // a monday
      habit.updateStartDate(to: startDate)
      habit.updateFrequency(to: .timesPerWeek(times: 3, resetDay: .sunday), on: startDate)
      
      XCTAssertEqual(startDate.weekdayIndex, Weekday.monday.rawValue)
      
      XCTAssertFalse(habit.isDue(on: startDate)) // monday
      XCTAssertFalse(habit.isDue(on: Cal.add(days: 1, to: startDate))) // tuesday
      XCTAssertFalse(habit.isDue(on: Cal.add(days: 2, to: startDate))) // wednesday
      XCTAssertFalse(habit.isDue(on: Cal.add(days: 3, to: startDate))) // thursday
      XCTAssertFalse(habit.isDue(on: Cal.add(days: 4, to: startDate))) // friday
      XCTAssertFalse(habit.isDue(on: Cal.add(days: 5, to: startDate))) // saturday
      XCTAssertTrue(habit.isDue(on: Cal.add(days: 6, to: startDate))) // sunday
   }
   
   func testXTimesPerWeek2() throws {
      let startDate = df.date(from: "7-17-2023")! // a monday
      habit.updateStartDate(to: startDate)
      habit.updateFrequency(to: .timesPerWeek(times: 3, resetDay: .wednesday), on: startDate)
      
      XCTAssertEqual(startDate.weekdayIndex, Weekday.monday.rawValue)
      
      XCTAssertFalse(habit.isDue(on: startDate)) // monday
      XCTAssertFalse(habit.isDue(on: Cal.add(days: 1, to: startDate))) // tuesday
      XCTAssertTrue(habit.isDue(on: Cal.add(days: 2, to: startDate))) // wednesday
      XCTAssertFalse(habit.isDue(on: Cal.add(days: 3, to: startDate))) // thursday
      XCTAssertFalse(habit.isDue(on: Cal.add(days: 4, to: startDate))) // friday
      XCTAssertFalse(habit.isDue(on: Cal.add(days: 5, to: startDate))) // saturday
      XCTAssertFalse(habit.isDue(on: Cal.add(days: 6, to: startDate))) // sunday
   }
}
