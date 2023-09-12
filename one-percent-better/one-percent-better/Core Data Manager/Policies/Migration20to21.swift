//
//  Migration20to21.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 9/11/23.
//

import Foundation
import CoreData

/// In 1.1.5, the option to choose the start of the week was added. The new default was set to
/// monday instead of sunday, so the raw value of the enum holding the weekdays was shifted
/// from 0 being sunday to 0 being monday. This causes the frequencies containing the weekday
/// raw enums to shift, and need to be adjusted by subtracting 1 and modulus 7 (or adding 6 and
/// modulo 7 for a positive int).
class Migration20to21: NSEntityMigrationPolicy {
    @objc func mapResetDay(_ sourceValue: NSNumber) -> NSNumber {
        let shifted = (sourceValue.intValue + 6) % 7
        return NSNumber(value: shifted)
    }
    
    @objc func mapWeekdays(_ sourceValue: NSArray) -> NSArray {
        let updatedArray = sourceValue.map { (element) -> Int in
            if let intElement = element as? Int {
                let shifted = (intElement + 6) % 7
                return shifted
            }
            assertionFailure("Should only contain Int")
            return 0
        }
        
        return NSArray(array: updatedArray)
    }
}
