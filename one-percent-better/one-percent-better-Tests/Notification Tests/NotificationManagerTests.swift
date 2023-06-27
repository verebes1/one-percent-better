//
//  NotificationManagerTests.swift
//  one-percent-betterTests
//
//  Created by Jeremy Cook on 6/24/23.
//

import XCTest
@testable import ___Better

class MockUserNotificationCenter: UserNotificationCenter {
   func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
      return true
   }
   
   func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
      
   }
   
   func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?) {
      
   }
   
   func add(_ request: UNNotificationRequest) async throws {
      
   }
   
   func pendingNotificationRequests() async -> [UNNotificationRequest] {
      return []
   }
}

final class NotificationManagerTests: XCTestCase {
   
   let nm = NotificationManager(moc: CoreDataManager.previews.mainContext)
   let context = CoreDataManager.previews.mainContext
   var habit: Habit!
   
   override func setUpWithError() throws {
      nm.userNotificationCenter = MockUserNotificationCenter()
      habit = try! Habit(context: context, name: "Cook")
      habit.notificationManager = nm
   }
   
   override func tearDownWithError() throws {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
      let habits = Habit.habits(from: context)
      for habit in habits {
         context.delete(habit)
      }
      try context.save()
   }
   
   func waitForRebalance() async throws {
      while nm.rebalanceTask != nil {
         try await Task.sleep(for: .milliseconds(100))
      }
   }
   
   /// Create a single notification on a single habit. It should have (MAX_NOTIFS - 1) scheduled
   /// It's MAX - 1 because the first notification is cleaned up because we are scheduling it for right now
   func testSingleNotification() async throws {
      NotificationManager.MAX_NOTIFS = 10
      let notif = SpecificTimeNotification(context: context, time: Date())
      notif.openAIDelegate = MockOpenAI()
      habit.addNotification(notif)
      
      try await waitForRebalance()
      XCTAssertEqual(notif.scheduledNotificationsArray.count, NotificationManager.MAX_NOTIFS - 1)
      XCTAssertEqual(notif.scheduledNotificationsArray.first!.index, 1)
   }
   
   func testPendingNotifications() async throws {
      let pendingNotificationRequests = await nm.userNotificationCenter.pendingNotificationRequests()
      print("\(pendingNotificationRequests)")
      XCTAssertEqual(pendingNotificationRequests.count, 0)
   }
}
