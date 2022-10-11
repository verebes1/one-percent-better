//
//  MigrationModel8to9.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 9/27/22.
//

import Foundation
import CoreData

class MigrationModel8to9: NSEntityMigrationPolicy {
   @objc func typeFor(frequency: NSNumber) -> [NSNumber] {
      return [frequency]
   }
   
   @objc func typeFor(frequencyDates: NSDate) -> [NSDate] {
      return [frequencyDates]
   }
   
   @objc func typeFor(timesPerDay: Int) -> [Int] {
      print("tpd: \(timesPerDay)")
      return [timesPerDay]
   }
   
   @objc func typeFor(daysPerWeek: [Int]) -> [[Int]] {
      if daysPerWeek.isEmpty {
         return [[2,4]]
      } else {
         return [daysPerWeek]
      }
   }
}
