//
//  MigrationModel10-to-11.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/26/22.
//

import Foundation
import CoreData

class MigrationModel10to11: NSEntityMigrationPolicy {
   @objc func typeFor(id: NSString) -> UUID {
      return UUID()
   }
}
