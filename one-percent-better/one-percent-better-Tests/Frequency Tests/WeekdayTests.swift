//
//  WeekdayTests.swift
//  one-percent-betterTests
//
//  Created by Jeremy Cook on 2/18/23.
//

import XCTest
@testable import One_Percent_Better

final class WeekdayTests: XCTestCase {

    func testExample() throws {
       XCTAssertEqual(Weekday.positiveDifference(from: .monday, to: .monday), 0)
       XCTAssertEqual(Weekday.positiveDifference(from: .monday, to: .tuesday), 1)
       XCTAssertEqual(Weekday.positiveDifference(from: .monday, to: .wednesday), 2)
       XCTAssertEqual(Weekday.positiveDifference(from: .monday, to: .saturday), 5)
       XCTAssertEqual(Weekday.positiveDifference(from: .monday, to: .sunday), 6)
       
       XCTAssertEqual(Weekday.positiveDifference(from: .wednesday, to: .monday), 5)
       XCTAssertEqual(Weekday.positiveDifference(from: .wednesday, to: .tuesday), 6)
       
       XCTAssertEqual(Weekday.positiveDifference(from: .friday, to: .monday), 3)
       XCTAssertEqual(Weekday.positiveDifference(from: .friday, to: .wednesday), 5)
       XCTAssertEqual(Weekday.positiveDifference(from: .friday, to: .thursday), 6)
    }

}
