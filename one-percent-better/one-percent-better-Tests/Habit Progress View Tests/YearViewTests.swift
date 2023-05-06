//
//  YearViewTests.swift
//  one-percent-betterTests
//
//  Created by Jeremy Cook on 4/29/23.
//

import XCTest
@testable import One_Percent_Better

final class YearViewTests: XCTestCase {
   
   var yvm: YearViewModel!
   
   override func setUpWithError() throws {
      yvm = YearViewModel()
   }
   
   override func tearDownWithError() throws {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
   }
   
   func testJanuaryOffset() {
      XCTAssertEqual(yvm.januaryOffset(year: 2023), Weekday.sunday.rawValue)
      XCTAssertEqual(yvm.januaryOffset(year: 2022), Weekday.saturday.rawValue)
      XCTAssertEqual(yvm.januaryOffset(year: 2021), Weekday.friday.rawValue)
      XCTAssertEqual(yvm.januaryOffset(year: 2020), Weekday.wednesday.rawValue)
      XCTAssertEqual(yvm.januaryOffset(year: 2019), Weekday.tuesday.rawValue)
   }
   
}
