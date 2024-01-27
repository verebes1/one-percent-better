//
//  PendingNotification.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/17/23.
//

import Foundation
import UIKit

/// A notification which hasn't been delivered yet
struct PendingNotification: Comparable {
    let identifier: String
    let id: String
    let index: Int
    let date: Date
    let message: String
    
    static func < (lhs: PendingNotification, rhs: PendingNotification) -> Bool {
        lhs.date < rhs.date
    }
}

extension UNNotificationRequest {
    /// Convert a UNNotificationRequest into a PendingNotification type for easier manipulation
    var pendingNotification: PendingNotification? {
        guard let calTrigger = self.trigger as? UNCalendarNotificationTrigger else {
            return nil
        }
        
        let dateComponents = calTrigger.dateComponents
        guard dateComponents.day != nil,
              dateComponents.month != nil,
              dateComponents.year != nil,
              dateComponents.hour != nil,
              dateComponents.minute != nil,
              let date = Cal.date(from: dateComponents) else {
            return nil
        }
        
        // identifier example: OnePercentBetter&3F181D4B-10E8-4F99-A77B-65F00D197AAE&2
        let idComponents = self.identifier.components(separatedBy: "&")
        guard idComponents.count == 3 else {
            return nil
        }
        
        let id = idComponents[1]
        guard let index = Int(idComponents[2]) else {
            return nil
        }
        let body = self.content.body
        return PendingNotification(identifier: self.identifier, id: id, index: index, date: date, message: body)
    }
}
