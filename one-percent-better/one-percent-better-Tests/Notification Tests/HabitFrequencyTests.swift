//
//  HabitFrequencyTests.swift
//  one-percent-betterTests
//
//  Created by Jeremy Cook on 7/11/23.
//

import XCTest
@testable import One_Percent_Better

final class HabitFrequencyTests: XCTestCase {
   
   func testEqualType() throws {
      XCTAssertTrue(HabitFrequency.timesPerDay(1).equalType(to: HabitFrequency.timesPerDay(2)))
      XCTAssertTrue(HabitFrequency.specificWeekdays([.monday, .tuesday]).equalType(to: HabitFrequency.specificWeekdays([.friday])))
      XCTAssertTrue(HabitFrequency.timesPerWeek(times: 3, resetDay: .sunday).equalType(to: HabitFrequency.timesPerWeek(times: 1, resetDay: .friday)))
      
      XCTAssertFalse(HabitFrequency.timesPerDay(1).equalType(to: HabitFrequency.specificWeekdays([.monday, .tuesday])))
      XCTAssertFalse(HabitFrequency.timesPerDay(1).equalType(to: HabitFrequency.timesPerWeek(times: 3, resetDay: .sunday)))
      XCTAssertFalse(HabitFrequency.specificWeekdays([.monday, .tuesday]).equalType(to: HabitFrequency.timesPerWeek(times: 3, resetDay: .sunday)))
   }
}
