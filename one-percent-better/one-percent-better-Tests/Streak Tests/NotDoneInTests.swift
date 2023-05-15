//
//  NotDoneInTests.swift
//  one-percent-betterTests
//
//  Created by Jeremy Cook on 5/15/23.
//

import XCTest
import CoreData
@testable import One_Percent_Better

final class NotDoneInTests: XCTestCase {
   
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
   
   func testNotDoneInFrequencyChange() throws {
      
      let startWednesday = df.date(from: "12-7-2022")!
      habit.updateStartDate(to: startWednesday)
      
      XCTAssertEqual(habit.notDoneInDays(on: startWednesday), 0)
      habit.markCompleted(on: startWednesday)
      
      
      habit.changeFrequency(to: .timesPerWeek(times: 4, resetDay: .sunday))
      
      
   }
   
}
