//
//  MigrationModel2to3.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 2/2/22.
//

import Foundation
import CoreData


class MigrationModel2to3: NSEntityMigrationPolicy {
    @objc func typeFor(notificationTime: NSDateComponents?) -> NSDate? {
        if let time = notificationTime,
           let date = Calendar.current.date(from: time as DateComponents) {
            return date as NSDate
        } else {
            return nil
        }
    }
}
