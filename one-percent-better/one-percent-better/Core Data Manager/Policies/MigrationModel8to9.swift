//
//  MigrationModel8to9.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 9/27/22.
//

import Foundation
import CoreData

@objc(MigrationModel8to9)
class MigrationModel8to9: NSEntityMigrationPolicy {
    @objc func typeFor(frequency: NSNumber) -> [NSNumber] {
        return [frequency]
    }
}
