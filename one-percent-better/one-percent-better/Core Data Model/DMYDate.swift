//
//  DMYDate.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/31/22.
//

import Foundation

/// Day Month Year Date
struct DMYDate: Hashable {
   
   var df: DateFormatter {
      let df = DateFormatter()
      df.dateFormat = "MM-dd-yyyy"
      return df
   }
   
   var date: Date
   
   init(_ date: Date) {
      self.date = date
   }
   
   var dateString: String {
      df.string(from: date)
   }
   
   static func == (lhs: DMYDate, rhs: DMYDate) -> Bool {
      return lhs.dateString == rhs.dateString
   }
   
   func hash(into hasher: inout Hasher) {
      hasher.combine(dateString)
   }
}
