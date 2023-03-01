//
//  Habit+WasCompletedOnTests.swift
//  one-percent-betterTests
//
//  Created by Jeremy Cook on 2/13/23.
//

import XCTest
@testable import ___Better

final class Habit_WasCompletedOnTests: XCTestCase {
   
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

    func testExample() throws {
        
    }
}
