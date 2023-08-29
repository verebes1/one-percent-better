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
   
   func testChangeStartDate() throws {
      let today = Date().startOfDay
      XCTAssertTrue(Cal.isDate(habit.startDate, inSameDayAs: today))
      XCTAssertTrue(Cal.isDate(habit.frequenciesArray.first!.startDate, inSameDayAs: today))
      
      let startDate = df.date(from: "1-29-2023")!
      habit.updateStartDate(to: startDate)
      XCTAssertTrue(Cal.isDate(habit.startDate, inSameDayAs: startDate))
      XCTAssertTrue(Cal.isDate(habit.frequenciesArray.first!.startDate, inSameDayAs: startDate))
      
      let threeDaysAgo = Cal.add(days: -3, to: startDate)
      habit.updateStartDate(to: threeDaysAgo)
      XCTAssertTrue(Cal.isDate(habit.startDate, inSameDayAs: threeDaysAgo))
      XCTAssertTrue(Cal.isDate(habit.frequenciesArray.first!.startDate, inSameDayAs: threeDaysAgo))
      XCTAssertEqual(habit.frequenciesArray.count, 1)
      
      let threeDaysFromNow = Cal.add(days: 3, to: startDate)
      habit.updateStartDate(to: threeDaysFromNow)
      XCTAssertTrue(Cal.isDate(habit.startDate, inSameDayAs: threeDaysFromNow))
      XCTAssertTrue(Cal.isDate(habit.frequenciesArray.first!.startDate, inSameDayAs: threeDaysFromNow))
      XCTAssertEqual(habit.frequenciesArray.count, 1)
   }
   
   /// Ask for frequency before start date of habit
   func testFrequencyBeforeStartDate() throws {
      let threeDaysAgo = Cal.add(days: -3)
      XCTAssertNil(habit.frequency(on: threeDaysAgo))
   }

   /// Test adding two of the same frequencies one after another, they should get squashed
   /// in the frequencies array
   func testFrequencySquash() throws {
      let startDate = df.date(from: "2-1-2023")!
      habit.updateStartDate(to: startDate)
      habit.updateFrequency(to: .timesPerDay(1), on: df.date(from: "2-1-2023")!)
      habit.updateFrequency(to: .timesPerDay(2), on: df.date(from: "2-2-2023")!)
      habit.updateFrequency(to: .timesPerDay(3), on: df.date(from: "2-3-2023")!)
      
      XCTAssertEqual(habit.frequency(on: df.date(from: "2-1-2023")!), .timesPerDay(1))
      XCTAssertEqual(habit.frequency(on: df.date(from: "2-2-2023")!), .timesPerDay(2))
      XCTAssertEqual(habit.frequency(on: df.date(from: "2-3-2023")!), .timesPerDay(3))
      
      habit.updateFrequency(to: .timesPerDay(3), on: df.date(from: "2-2-2023")!)
      
      XCTAssertEqual(habit.frequency(on: df.date(from: "2-1-2023")!), .timesPerDay(1))
      XCTAssertEqual(habit.frequency(on: df.date(from: "2-2-2023")!), .timesPerDay(3))
      XCTAssertEqual(habit.frequency(on: df.date(from: "2-3-2023")!), .timesPerDay(3))
      XCTAssertEqual(habit.frequenciesArray.count, 2)
   }
   
   /// Test updating a frequency in the middle of two other frequencies
   func testUpdateFrequencyInMiddle() {
      let startDate = df.date(from: "2-1-2023")!
      habit.updateStartDate(to: startDate)
      habit.updateFrequency(to: .timesPerDay(1), on: df.date(from: "2-1-2023")!)
      habit.updateFrequency(to: .timesPerDay(2), on: df.date(from: "2-5-2023")!)
      
      XCTAssertEqual(habit.frequency(on: df.date(from: "2-1-2023")!), .timesPerDay(1))
      XCTAssertEqual(habit.frequency(on: df.date(from: "2-5-2023")!), .timesPerDay(2))
      
      habit.updateFrequency(to: .timesPerWeek(times: 5, resetDay: .sunday), on: df.date(from: "2-3-2023")!)
      XCTAssertEqual(habit.frequency(on: df.date(from: "2-1-2023")!), .timesPerDay(1))
      XCTAssertEqual(habit.frequency(on: df.date(from: "2-3-2023")!), .timesPerWeek(times: 5, resetDay: .sunday))
      XCTAssertEqual(habit.frequency(on: df.date(from: "2-4-2023")!), .timesPerWeek(times: 5, resetDay: .sunday))
      XCTAssertEqual(habit.frequency(on: df.date(from: "2-5-2023")!), .timesPerDay(2))
      XCTAssertEqual(habit.frequenciesArray.count, 3)
   }
}
