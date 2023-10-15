//
//  NotificationManagerTests.swift
//  one-percent-betterTests
//
//  Created by Jeremy Cook on 6/24/23.
//

import XCTest
@testable import One_Percent_Better

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
    var habit2: Habit!
    
    override func setUpWithError() throws {
        nm.userNotificationCenter = MockUserNotificationCenter()
        nm.notificationGenerator = MockNotificationGenerator()
        habit = try! Habit(context: context, name: "Cook")
        habit.notificationManager = nm
        habit2 = try! Habit(context: context, name: "Eat Healthy")
        habit2.notificationManager = nm
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
        let notif = SpecificTimeNotification(context: context, time: Date())
        habit.addToNotifications(notif)
        let content = notif.generateNotificationContent(message: "test message")
        XCTAssertEqual(content.title, habit.name)
        XCTAssertEqual(content.body, "test message")
        XCTAssertEqual(content.sound, UNNotificationSound.default)
    }
    
    func waitForRebalance(timeout: Double = 1) async throws {
        let expectation = expectation(description: "rebalance task")
        expectation.expectedFulfillmentCount = 1
        
        Task.detached { [self, expectation] in
            while self.nm.rebalanceRequestCount != 0 {
                try await Task.sleep(for: .milliseconds(100))
            }
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: timeout)
    }
    
    /// Create a single notification on a single habit. It should have (MAX_NOTIFS - 1) scheduled
    /// It's MAX - 1 because the first notification is cleaned up because we are scheduling it for right now
    func testSingleNotification() async throws {
        let notif = SpecificTimeNotification(context: context, time: Date())
        habit.addNotification(notif)
        
        try await waitForRebalance()
        XCTAssertEqual(notif.scheduledNotificationsArray.count, NotificationManager.MAX_NOTIFS - 1)
        XCTAssertEqual(notif.scheduledNotificationsArray.first!.index, 1)
    }
    
    /// Test a single notification but with MAX_NOTIFS set to a smaller max
    func testSingleNotification2() async throws {
        let notif = SpecificTimeNotification(context: context, time: Date())
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
        let notif = SpecificTimeNotification(context: context, time: scheduledTime)
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
    
    @MainActor func testTwoNotificationsTwoHabits() async throws {
        let notif1 = SpecificTimeNotification(context: context, time: Date())
        let notif2 = SpecificTimeNotification(context: context, time: Date())
        
        habit.addNotification(notif1)
        habit2.addNotification(notif2)
        
        try await waitForRebalance(timeout: 5)
        XCTAssertEqual(notif1.scheduledNotificationsArray.count, (NotificationManager.MAX_NOTIFS / 2) - 1)
        XCTAssertEqual(notif1.scheduledNotificationsArray.first!.index, 1)
        
        XCTAssertEqual(notif2.scheduledNotificationsArray.count, (NotificationManager.MAX_NOTIFS / 2) - 1)
        XCTAssertEqual(notif2.scheduledNotificationsArray.first!.index, 1)
    }
    
    @MainActor func testDeleteNotificationWhileRebalancing() async throws {
        let notif = SpecificTimeNotification(context: context, time: Date())
        habit.addNotification(notif)
        try await Task.sleep(for: .milliseconds(Int.random(in: 1 ... 1000)))
        habit.removeFromNotifications(notif)
        XCTAssertEqual(habit.notificationsArray.count, 0)
    }
    
    func testTwoNotificationsOneHabit() async throws {
        let notif1 = SpecificTimeNotification(context: context, time: Date())
        let notif2 = SpecificTimeNotification(context: context, time: Date())
        
        habit.addNotification(notif1)
        habit.addNotification(notif2)
        
        try await waitForRebalance()
        XCTAssertEqual(notif1.scheduledNotificationsArray.count, (NotificationManager.MAX_NOTIFS / 2) - 1)
        XCTAssertEqual(notif1.scheduledNotificationsArray.first!.index, 1)
        
        XCTAssertEqual(notif2.scheduledNotificationsArray.count, (NotificationManager.MAX_NOTIFS / 2) - 1)
        XCTAssertEqual(notif2.scheduledNotificationsArray.first!.index, 1)
    }
    
    func testThreeNotifications() async throws {
        let notif1 = SpecificTimeNotification(context: context, time: Date())
        let notif2 = SpecificTimeNotification(context: context, time: Date())
        let notif3 = SpecificTimeNotification(context: context, time: Date())
        
        let habit2 = try! Habit(context: context, name: "Eat Healthy")
        let habit3 = try! Habit(context: context, name: "Clean")
        
        habit.addNotification(notif1)
        habit2.addNotification(notif2)
        habit3.addNotification(notif3)
        
        try await waitForRebalance()
        XCTAssertEqual(notif1.scheduledNotificationsArray.count, (NotificationManager.MAX_NOTIFS / 3) - 1)
        XCTAssertEqual(notif1.scheduledNotificationsArray.first!.index, 1)
        
        XCTAssertEqual(notif2.scheduledNotificationsArray.count, (NotificationManager.MAX_NOTIFS / 3) - 1)
        XCTAssertEqual(notif2.scheduledNotificationsArray.first!.index, 1)
        
        XCTAssertEqual(notif3.scheduledNotificationsArray.count, (NotificationManager.MAX_NOTIFS / 3) - 1)
        XCTAssertEqual(notif3.scheduledNotificationsArray.first!.index, 1)
    }
    
    func testPendingNotifications() async throws {
        let pendingNotificationRequests = await nm.userNotificationCenter.pendingNotificationRequests()
        print("\(pendingNotificationRequests)")
        XCTAssertEqual(pendingNotificationRequests.count, 0)
    }
}
