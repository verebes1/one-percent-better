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
   
   func testNotificationContent() {
      let notif = SpecificTimeNotification(context: context, notificationGenerator: MockNotificationGenerator(), time: Date())
      habit.addToNotifications(notif)
      let content = notif.generateNotificationContent(message: "test message")
      XCTAssertEqual(content.title, habit.name)
      XCTAssertEqual(content.body, "test message")
      XCTAssertEqual(content.sound, UNNotificationSound.default)
   }
   
   func waitForRebalance() async throws {
      while nm.rebalanceTask != nil {
         try await Task.sleep(for: .milliseconds(100))
      }
   }
   
   /// Create a single notification on a single habit. It should have (MAX_NOTIFS - 1) scheduled
   /// It's MAX - 1 because the first notification is cleaned up because we are scheduling it for right now
   func testSingleNotification() async throws {
      let notif = SpecificTimeNotification(context: context, notificationGenerator: MockNotificationGenerator(), time: Date())
      habit.addNotification(notif)
      
      try await waitForRebalance()
      XCTAssertEqual(notif.scheduledNotificationsArray.count, NotificationManager.MAX_NOTIFS - 1)
      XCTAssertEqual(notif.scheduledNotificationsArray.first!.index, 1)
   }
   
   /// Test a single notification but with MAX_NOTIFS set to a smaller max
   func testSingleNotification2() async throws {
      NotificationManager.MAX_NOTIFS = 10
      let notif = SpecificTimeNotification(context: context, notificationGenerator: MockNotificationGenerator(), time: Date())
      habit.addNotification(notif)
      
      try await waitForRebalance()
      XCTAssertEqual(notif.scheduledNotificationsArray.count, NotificationManager.MAX_NOTIFS - 1)
      XCTAssertEqual(notif.scheduledNotificationsArray.first!.index, 1)
   }
   
   /// Create a single notification with a future time scheduled. It should have MAX_NOTIFS scheduled if
   /// the future time is in the same day as today, otherwise it will have MAX_NOTIFS - 1
   func testSingleNotificationScheduledAhead() async throws {
      let now = Date()
      let scheduledTime = Date(timeInterval: 100, since: now)
      let notif = SpecificTimeNotification(context: context, notificationGenerator: MockNotificationGenerator(), time: scheduledTime)
      habit.addNotification(notif)
      
      try await waitForRebalance()
      if Cal.isDate(now, inSameDayAs: scheduledTime) {
         XCTAssertEqual(notif.scheduledNotificationsArray.count, NotificationManager.MAX_NOTIFS)
         XCTAssertEqual(notif.scheduledNotificationsArray.first!.index, 0)
      } else {
         XCTAssertEqual(notif.scheduledNotificationsArray.count, NotificationManager.MAX_NOTIFS - 1)
         XCTAssertEqual(notif.scheduledNotificationsArray.first!.index, 1)
      }
   }
   
   func testPendingNotifications() async throws {
      let pendingNotificationRequests = await nm.userNotificationCenter.pendingNotificationRequests()
      print("\(pendingNotificationRequests)")
      XCTAssertEqual(pendingNotificationRequests.count, 0)
   }
}
