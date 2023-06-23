//
//  RandomTimeTests.swift
//  one-percent-betterTests
//
//  Created by Jeremy Cook on 3/7/23.
//

import XCTest
@testable import ___Better

final class RandomTimeTests: XCTestCase {
   
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
   
//   func testRandomTime() {
//      var startTimeDefault: Date = {
//         var components = DateComponents()
//         components.hour = 9
//         components.minute = 0
//         return Cal.date(from: components)!
//      }()
//      
//      var endTimeDefault: Date = {
//         var components = DateComponents()
//         components.hour = 17
//         components.minute = 0
//         return Cal.date(from: components)!
//      }()
//      
//      let n = 10
//      let randomTimes = habit.randomTimes(between: startTimeDefault, and: endTimeDefault, n: n)
//   }
}
