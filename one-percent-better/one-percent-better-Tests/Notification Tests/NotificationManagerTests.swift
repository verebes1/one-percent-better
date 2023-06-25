//
//  NotificationManagerTests.swift
//  one-percent-betterTests
//
//  Created by Jeremy Cook on 6/24/23.
//

import XCTest
@testable import ___Better

final class NotificationManagerTests: XCTestCase {
   
   let nm = NotificationManager(moc: CoreDataManager.previews.mainContext)
   let context = CoreDataManager.previews.mainContext
   var habit: Habit!
   
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
   
   func testSingleNotification() throws {
      let notif = SpecificTimeNotification(context: context, time: Date())
      habit.addNotification(notif)
      
   }
   
   func testPendingNotifications() throws {
      
   }
}
