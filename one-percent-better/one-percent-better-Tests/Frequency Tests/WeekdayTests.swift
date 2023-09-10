////
////  WeekdayTests.swift
////  one-percent-betterTests
////
////  Created by Jeremy Cook on 2/18/23.
////
//
//import XCTest
//@testable import One_Percent_Better
//
//final class WeekdayTests: XCTestCase {
//    
//    /// Test monday has raw value 0, tuesday raw value 1, etc.
//    func testRawValue() throws {
//        let monday = df.date(from: "8-14-2023")!
//        for i in 0 ..< 7 {
//            let day = Cal.add(days: i, to: monday)
//            XCTAssertEqual(Weekday(day).rawValue, i)
//        }
//    }
//    
//    /// Test the adjusted index of the weekday based on the start of week
//    func testIndex() throws {
//        let monday = Weekday(df.date(from: "8-14-2023")!)
//        let wednesday = Weekday(df.date(from: "8-16-2023")!)
//        
//        Weekday.startOfWeek = .monday
//        XCTAssertEqual(monday.index, 0)
//        XCTAssertEqual(wednesday.index, 2)
//        
//        Weekday.startOfWeek = .sunday
//        XCTAssertEqual(monday.index, 1)
//        XCTAssertEqual(wednesday.index, 3)
//        
//        Weekday.startOfWeek = .saturday
//        XCTAssertEqual(monday.index, 2)
//        XCTAssertEqual(wednesday.index, 4)
//        
//        Weekday.startOfWeek = .thursday
//        XCTAssertEqual(monday.index, 4)
//        XCTAssertEqual(wednesday.index, 6)
//        
//        Weekday.startOfWeek = .tuesday
//        XCTAssertEqual(monday.index, 6)
//        XCTAssertEqual(wednesday.index, 1)
//    }
//
//    func testPositiveDifference() throws {
//       XCTAssertEqual(Weekday.positiveDifference(from: .monday, to: .monday), 0)
//       XCTAssertEqual(Weekday.positiveDifference(from: .monday, to: .tuesday), 1)
//       XCTAssertEqual(Weekday.positiveDifference(from: .monday, to: .wednesday), 2)
//       XCTAssertEqual(Weekday.positiveDifference(from: .monday, to: .saturday), 5)
//       XCTAssertEqual(Weekday.positiveDifference(from: .monday, to: .sunday), 6)
//       
//       XCTAssertEqual(Weekday.positiveDifference(from: .wednesday, to: .monday), 5)
//       XCTAssertEqual(Weekday.positiveDifference(from: .wednesday, to: .tuesday), 6)
//       
//       XCTAssertEqual(Weekday.positiveDifference(from: .friday, to: .monday), 3)
//       XCTAssertEqual(Weekday.positiveDifference(from: .friday, to: .wednesday), 5)
//       XCTAssertEqual(Weekday.positiveDifference(from: .friday, to: .thursday), 6)
//    }
//
//}
