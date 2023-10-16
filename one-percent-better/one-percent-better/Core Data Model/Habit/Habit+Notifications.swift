//
//  Habit+Notifications.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 3/3/23.
//

import Foundation
import UIKit
import CoreData

extension Habit {
    func addNotification(_ notification: Notification) {
        self.addToNotifications(notification)
        notificationManager.rebalanceHabitNotifications()
    }
    
    func addNotifications(_ notifications: [Notification]) {
        for notif in notifications {
            self.addToNotifications(notif)
        }
        if !notifications.isEmpty {
            notificationManager.rebalanceHabitNotifications()
        }
    }
    
    func removeNotifications(on date: Date, habitID: UUID) async {
        var rebalance = false
        if await notificationManager.rebalanceManager.isRebalancing {
            rebalance = true
            notificationManager.cancelRebalance()
        }
        
        // TODO: 1.1.6 Move this onto the backgroundContext because we are async!!
        await notificationManager.backgroundContext.perform { [habitID] in
            var notifications: [Notification]
            do {
                let fetchRequest: NSFetchRequest<Habit> = Habit.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", habitID as CVarArg)
                if let habit = try self.notificationManager.backgroundContext.fetch(fetchRequest).first {
                    notifications = habit.notificationsArray
                } else {
                    return
                }
            } catch {
                assertionFailure("Unable to find notification in Core Database")
                return
            }
            
            for notification in notifications {
                for scheduled in notification.scheduledNotificationsArray {
                    if Cal.isDate(date, inSameDayAs: scheduled.date), scheduled.isScheduled {
                        let identifier = "OnePercentBetter&\(scheduled.notification.id.uuidString)&\(scheduled.index)"
                        print("remove notification with id: \(identifier)")
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
                        scheduled.isScheduled = false
                    }
                }
            }
        }
        
        await removeDeliveredNotifications()
        
        if rebalance {
            notificationManager.rebalanceHabitNotifications()
        }
    }
    
    @MainActor func removeDeliveredNotifications() {
        moc.perform {
            for habitNotif in self.notificationsArray {
                let id = habitNotif.id
                UNUserNotificationCenter.current().getDeliveredNotifications { [id] notifs in
                    for notif in notifs {
                        if notif.request.identifier.hasPrefix("OnePercentBetter&\(id)") {
                            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notif.request.identifier])
                        }
                    }
                }
            }
        }
    }
    
    func addNotificationsBack(on date: Date, habitID: UUID) async {
        var rebalance = false
        if await notificationManager.rebalanceManager.isRebalancing {
            rebalance = true
            notificationManager.cancelRebalance()
        }
        
        // TODO: 1.1.6 Move this onto the backgroundContext because we are async!!
        // Also move this to NofiticationManager instead of on habit
        await notificationManager.backgroundContext.perform { [habitID] in
            var notifications: [Notification]
            do {
                let fetchRequest: NSFetchRequest<Habit> = Habit.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", habitID as CVarArg)
                if let habit = try self.notificationManager.backgroundContext.fetch(fetchRequest).first {
                    notifications = habit.notificationsArray
                } else {
                    return
                }
            } catch {
                assertionFailure("Unable to find notification in Core Database")
                return
            }
            
            for notification in notifications {
                for scheduled in notification.scheduledNotificationsArray {
                    if Cal.isDate(date, inSameDayAs: scheduled.date), !scheduled.isScheduled {
                        let identifier = "OnePercentBetter&\(scheduled.notification.id.uuidString)&\(scheduled.index)"
                        let dayComponents = Cal.dateComponents([.day, .month, .year, .hour, .minute], from: scheduled.date)
                        let trigger = UNCalendarNotificationTrigger(dateMatching: dayComponents, repeats: false)
                        let notifContent = notification.generateNotificationContent(message: scheduled.string)
                        let request = UNNotificationRequest(identifier: identifier, content: notifContent, trigger: trigger)
                        print("adding notification with id: \(identifier)")
                        UNUserNotificationCenter.current().add(request) { error in
                            if let error = error {
                                print("error adding notification back: \(error.localizedDescription)")
                            }
                        }
                        scheduled.isScheduled = true
                    }
                }
            }
        }
        
        if rebalance {
            notificationManager.rebalanceHabitNotifications()
        }
    }
}
