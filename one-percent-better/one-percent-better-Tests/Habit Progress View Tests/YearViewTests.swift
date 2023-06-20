//
//  YearViewTests.swift
//  one-percent-betterTests
//
//  Created by Jeremy Cook on 4/29/23.
//

import XCTest
@testable import One_Percent_Better

final class YearViewTests: XCTestCase {
   
   
   override func setUpWithError() throws {
      
   }
   
   override func tearDownWithError() throws {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
   }
   
//   func testJanuaryOffset() {
//      XCTAssertEqual(yvm.januaryOffset(year: 2023), Weekday.sunday.rawValue)
//      XCTAssertEqual(yvm.januaryOffset(year: 2022), Weekday.saturday.rawValue)
//      XCTAssertEqual(yvm.januaryOffset(year: 2021), Weekday.friday.rawValue)
//      XCTAssertEqual(yvm.januaryOffset(year: 2020), Weekday.wednesday.rawValue)
//      XCTAssertEqual(yvm.januaryOffset(year: 2019), Weekday.tuesday.rawValue)
//   }
   
   func daysOffsetFromYearStart(date: Date, year: Int) -> Int {
      let calendar = Calendar.current
      let startOfYear = calendar.date(from: DateComponents(year: year))!
      return calendar.dateComponents([.day], from: startOfYear, to: date).day!
   }
   
   func testDaysOffset() {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy/MM/dd"
      
      // Test January 1st
//      var date = dateFormatter.date(from: "2023/01/01")!
//      var days = daysOffsetFromYearStart(date: date)
//      XCTAssertEqual(days, 0)
//
//      // Test February 1st
//      date = dateFormatter.date(from: "2023/02/01")!
//      days = daysOffsetFromYearStart(date: date)
//      XCTAssertEqual(days, 31)
//
//      // Test March 1st, which is 60 days into a non-leap year
//      date = dateFormatter.date(from: "2023/03/01")!
//      days = daysOffsetFromYearStart(date: date)
//      XCTAssertEqual(days, 59)
//
//      // Test December 31st, which is 365 days into a non-leap year
//      date = dateFormatter.date(from: "2023/12/31")!
//      days = daysOffsetFromYearStart(date: date)
//      XCTAssertEqual(days, 364)
//
//      // Test February 29th of a leap year, which should be the 60th day
//      date = dateFormatter.date(from: "2024/02/29")!
//      days = daysOffsetFromYearStart(date: date)
//      XCTAssertEqual(days, 59)
      
      
      
      // Test January 1st, 2023 from the year 2023
      var date = dateFormatter.date(from: "2023/01/01")!
      var days = daysOffsetFromYearStart(date: date, year: 2023)
      XCTAssertEqual(days, 0)
      
      // Test February 1st, 2023 from the year 2023
      date = dateFormatter.date(from: "2023/02/01")!
      days = daysOffsetFromYearStart(date: date, year: 2023)
      XCTAssertEqual(days, 31)
      
      // Test March 1st, which is 60 days into a non-leap year
      date = dateFormatter.date(from: "2023/03/01")!
      days = daysOffsetFromYearStart(date: date, year: 2023)
      XCTAssertEqual(days, 59)
      
      // Test February 1st, 2023 from the year 2022 (should be 397 as it's more than a year later)
      date = dateFormatter.date(from: "2023/02/01")!
      days = daysOffsetFromYearStart(date: date, year: 2022)
      XCTAssertEqual(days, 396)
      
      // Test December 31st, 2023 from the year 2024 (should return a negative offset)
      date = dateFormatter.date(from: "2023/12/31")!
      days = daysOffsetFromYearStart(date: date, year: 2024)
      XCTAssertEqual(days, -1)
   }
   
}
