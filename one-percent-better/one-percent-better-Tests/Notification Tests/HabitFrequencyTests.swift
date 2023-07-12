//
//  HabitFrequencyTests.swift
//  one-percent-betterTests
//
//  Created by Jeremy Cook on 7/11/23.
//

import XCTest
@testable import ___Better

final class HabitFrequencyTests: XCTestCase {
   
   func testDescription() throws {
      XCTAssertEqual(HabitFrequency.timesPerDay(1).description, "1 time per day")
      XCTAssertEqual(HabitFrequency.timesPerDay(2).description, "2 times per day")
      XCTAssertEqual(HabitFrequency.timesPerDay(3).description, "3 times per day")
      
      XCTAssertEqual(HabitFrequency.specificWeekdays([.monday, .tuesday, .wednesday]).description, "every Monday, Tuesday, Wednesday")
      XCTAssertEqual(HabitFrequency.specificWeekdays([.sunday, .thursday, .saturday]).description, "every Sunday, Thursday, Saturday")
      XCTAssertEqual(HabitFrequency.specificWeekdays([.friday]).description, "every Friday")
      
      XCTAssertEqual(HabitFrequency.timesPerWeek(times: 1, resetDay: .sunday).description, "1 time per week beginning every Sunday")
      XCTAssertEqual(HabitFrequency.timesPerWeek(times: 3, resetDay: .monday).description, "3 times per week beginning every Monday")
   }
   
   func testEqualType() throws {
      XCTAssertTrue(HabitFrequency.timesPerDay(1).equalType(to: HabitFrequency.timesPerDay(2)))
      XCTAssertTrue(HabitFrequency.specificWeekdays([.monday, .tuesday]).equalType(to: HabitFrequency.specificWeekdays([.friday])))
      XCTAssertTrue(HabitFrequency.timesPerWeek(times: 3, resetDay: .sunday).equalType(to: HabitFrequency.timesPerWeek(times: 1, resetDay: .friday)))
      
      XCTAssertFalse(HabitFrequency.timesPerDay(1).equalType(to: HabitFrequency.specificWeekdays([.monday, .tuesday])))
      XCTAssertFalse(HabitFrequency.timesPerDay(1).equalType(to: HabitFrequency.timesPerWeek(times: 3, resetDay: .sunday)))
      XCTAssertFalse(HabitFrequency.specificWeekdays([.monday, .tuesday]).equalType(to: HabitFrequency.timesPerWeek(times: 3, resetDay: .sunday)))
   }
}
