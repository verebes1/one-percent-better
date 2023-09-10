//
//  NotificationManager.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 3/16/23.
//

import Foundation
import UIKit
import CoreData

protocol UserNotificationCenter {
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?)
    func add(_ request: UNNotificationRequest) async throws
    func pendingNotificationRequests() async -> [UNNotificationRequest]
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
}
extension UNUserNotificationCenter: UserNotificationCenter {}

class NotificationManager {
    
    static var shared = NotificationManager()
    var moc: NSManagedObjectContext
    static var MAX_NOTIFS = 60
    
    var permissionGranted = false
    
    /// Protocol for interfacing with UNUserNotificationCenter
    var userNotificationCenter: UserNotificationCenter = UNUserNotificationCenter.current()
    
    init(moc: NSManagedObjectContext = CoreDataManager.shared.mainContext) {
        self.moc = moc
    }
    
    func requestNotificationPermission() async -> Bool? {
        do {
            permissionGranted = try await userNotificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
            return permissionGranted
        } catch {
            print("Error getting notification permission")
            return nil
        }
    }
    
    struct PendingNotification: Comparable {
        let notifIDString: String
        let id: String
        let num: Int
        let date: Date
        let message: String
        
        static func < (lhs: PendingNotification, rhs: PendingNotification) -> Bool {
            lhs.date < rhs.date
        }
    }
    
    func pendingNotifications() async -> [PendingNotification] {
        let pendingNotificationRequests = await userNotificationCenter.pendingNotificationRequests()
        
        // Step 3: Sort pending notifications by date scheduled
        var pendingNotifications: [PendingNotification] = []
        for notif in pendingNotificationRequests {
            guard let calTrigger = notif.trigger as? UNCalendarNotificationTrigger else {
                assert(false)
                continue
            }
            
            let dateComponents = calTrigger.dateComponents
            guard dateComponents.day != nil,
                  dateComponents.month != nil,
                  dateComponents.year != nil,
                  dateComponents.hour != nil,
                  dateComponents.minute != nil else {
                continue
            }
            
            guard let date = Cal.date(from: dateComponents) else {
                assert(false)
                continue
            }
            
            let idComponents = notif.identifier.components(separatedBy: "&")
            
            guard idComponents.count == 3 else {
                assert(false)
                continue
            }
            
            let id = idComponents[1]
            guard let num = Int(idComponents[2]) else {
                assert(false)
                continue
            }
            let body = notif.content.body
            let pendingNotification = PendingNotification(notifIDString: notif.identifier, id: id, num: num, date: date, message: body)
            pendingNotifications.append(pendingNotification)
        }
        pendingNotifications = pendingNotifications.sorted()
        
        return pendingNotifications
    }
    
    @MainActor func cleanUpScheduledNotifications() async throws {
        let today = Date()
        var nextNotifDate: Date?
        if let (_, date, _) = try await getNextNotification() {
            nextNotifDate = date
        }
        let scheduledNotifications = moc.fetchArray(ScheduledNotification.self)
        
        for scheduledNotification in scheduledNotifications {
            if scheduledNotification.date < today {
                scheduledNotification.notification.removeFromScheduledNotifications(scheduledNotification)
            } else if let nextDate = nextNotifDate,
                      scheduledNotification.date >= nextDate {
                scheduledNotification.notification.removeFromScheduledNotifications(scheduledNotification)
            }
        }
    }
    
    /// Clean up any expired notifications, i.e. ones that are not from today
    @MainActor func cleanUpExpiredNotifications() async throws {
        let habits = moc.fetchArray(Habit.self)
        let notifs = await UNUserNotificationCenter.current().deliveredNotifications()
        for notif in notifs {
            // TODO: 1.1.5 Fix this for more notification frequency types!
            if !Cal.isDateInToday(notif.date) {
                UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notif.request.identifier])
            }
        }
    }
    
    @MainActor func removeNotification(_ notification: PendingNotification) async {
        var notifications: [Notification]
        do {
            let fetchRequest: NSFetchRequest<Notification> = Notification.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", notification.id)
            notifications = try moc.fetch(fetchRequest)
        } catch {
            assertionFailure("Unable to find notification in Core Database")
            return
        }
        
        for notif in notifications {
            guard let scheduledNotif = notif.scheduledNotificationsArray.first(where: { $0.index == notification.num }) else {
                continue
            }
            
            notif.unscheduledNotificationStrings.append(notification.message)
            notif.removeFromScheduledNotifications(scheduledNotif)
            moc.delete(scheduledNotif)
            return
        }
    }
    
    @MainActor func notificationTime(for notification: Notification) async -> DateComponents {
        if let specificTime = notification as? SpecificTimeNotification {
            let time = Cal.dateComponents([.hour, .minute], from: specificTime.time)
            return time
        } else if let randomTime = notification as? RandomTimeNotification {
            let time = randomTime.getRandomTime()
            return time
        }
        fatalError("Unable to get time for notification")
    }
    
    // MARK: Rebalance
    
    var rebalanceTask: Task<Void, Never>?
    var shouldRestartRebalance = false
    
    /// A boolean to indicate if there is rebalancing going on or not right now
    var rebalanceRequestCount = 0
    
    func rebalanceHabitNotifications() {
        rebalanceRequestCount += 1
        if let rt = rebalanceTask {
            rt.cancel()
            Task {
                while rebalanceTask != nil {
                    try? await Task.sleep(for: .seconds(0.3))
                    print("~W~ waiting for cancellation to restart new rebalance ~W~")
                }
                startRebalanceTask()
            }
        } else {
            print("~+~ Starting new rebalance task ~+~")
            startRebalanceTask()
        }
    }
    
    func startRebalanceTask() {
        rebalanceTask = Task {
            do {
                try await rebalanceHabitNotificationsTask()
            } catch {
                print("~-~ startRebalanceTask task was cancelled! ~-~")
            }
            rebalanceTask = nil
            rebalanceRequestCount -= 1
        }
    }
    
    func cancelRebalance() {
        rebalanceTask?.cancel()
    }
    
    @MainActor func createAndAddNotificationRequest(notification: Notification, index: Int, date: DateComponents) async throws {
        try Task.checkCancellation()
        let request = try await notification.createNotificationRequest(index: index, date: date)
        await addNotificationRequest(request: request)
    }
    
    func addNotificationRequest(request: UNNotificationRequest) async {
        do {
            try await userNotificationCenter.add(request)
        } catch {
            print("Error generating notification request: \(error.localizedDescription)")
        }
    }
    
    func rebalanceHabitNotificationsTask() async throws {
        
        print("~~~ Rebalancing habit notifications! ~~~")
        
        // Step 1: Get pending notifications
        var pendingNotifications = await pendingNotifications()
        var notificationAllowance = Self.MAX_NOTIFS - pendingNotifications.count
        
        print("notificationAllowance: \(notificationAllowance)")
        
        // Step 2: Keep adding new notifications until new scheduled date > latest pending notification request date,
        // or maximum number of notification requests is reached
        for _ in 0 ..< Self.MAX_NOTIFS {
            try Task.checkCancellation()
            
            guard let (notification, day, index) = try await getNextNotification() else {
                break
            }
            try Task.checkCancellation()
            
            let nextIndex = (index + 1) % Self.MAX_NOTIFS
            var dayAndTime = await notificationTime(for: notification)
            let dayComponents = Cal.dateComponents([.day, .month, .year,], from: day)
            dayAndTime.calendar = Cal
            dayAndTime.day = dayComponents.day
            dayAndTime.month = dayComponents.month
            dayAndTime.year = dayComponents.year
            let newDate = Cal.date(from: dayAndTime)!
            
            guard let lastPendingNotif = pendingNotifications.last else {
                // No pending notification requests, add new notification
                try await createAndAddNotificationRequest(notification: notification, index: nextIndex, date: dayAndTime)
                notificationAllowance -= 1
                continue
            }
            
            if newDate < lastPendingNotif.date && notificationAllowance <= 0 {
                pendingNotifications.removeLast()
                // Add notification message back in unscheduledNotifications list for that notif id
                await removeNotification(lastPendingNotif)
                
                // Remove the scheduled notification
                userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [lastPendingNotif.notifIDString])
                
                // Add new notification
                try await createAndAddNotificationRequest(notification: notification, index: nextIndex, date: dayAndTime)
                notificationAllowance -= 1
            } else {
                if notificationAllowance > 0 {
                    try await createAndAddNotificationRequest(notification: notification, index: nextIndex, date: dayAndTime)
                    notificationAllowance -= 1
                } else {
                    // Can't schedule any more notifications
                    break
                }
            }
        }
        
        // Step 3: Remove any already sent notifications from scheduled list
        try await cleanUpScheduledNotifications()
        
        // Remove any notifications from previous days
        try await cleanUpExpiredNotifications()
        
        await moc.perform {
            self.moc.assertSave()
        }
        
        print("~o~ Finished rebalancing habit notifications! ~o~")
    }
    
    /// Get the next due notification
    /// - Returns: A tuple containing the next due notification NSManageObject, the date it's scheduled for, and the index of the notification
    @MainActor func getNextNotification() async throws -> (notification: Notification, date: Date, index: Int)? {
        let habits = Habit.habits(from: moc)
        var nextNotifsAndDates: [(Notification, Date)] = []
        
        for habit in habits {
            for notif in habit.notificationsArray {
                let nextDate = notif.nextDue()
                nextNotifsAndDates.append((notif, nextDate))
            }
            try Task.checkCancellation()
        }
        
        nextNotifsAndDates = nextNotifsAndDates.sorted { $0.1 < $1.1 }
        
        if let hasNext = nextNotifsAndDates.first {
            let lastScheduledIndex = hasNext.0.scheduledNotificationsArray.last?.index ?? -1
            print("Next to-be scheduled notification: \(hasNext.0.habit.name), date: \(hasNext.1), index: \(lastScheduledIndex)")
            return (hasNext.0, hasNext.1, lastScheduledIndex)
        } else {
            return nil
        }
    }
}
