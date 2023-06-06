//
//  CoreDataManager.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 2/3/22.
//

import Foundation
import CoreData

enum CoreDataMigrationVersion: String, CaseIterable {
   case v1 = "mo_ikai"
   case v2 = "mo_ikai 2"
   case v3 = "mo_ikai 3"
   case v4 = "mo_ikai 4"
   case v5 = "mo_ikai 5"
   case v6 = "mo_ikai 6"
   case v7 = "mo_ikai 7"
   case v8 = "mo_ikai 8"
   case v9 = "mo_ikai 9"
   case v10 = "mo_ikai 10"
   case v11 = "mo_ikai 11"
   case v12 = "opb 12"
   case v13 = "opb 13"
   case v14 = "opb 14"
   case v15 = "opb 15"
   case v16 = "opb 16"
   case v17 = "opb 17"
   case v18 = "opb 18"
   case v19 = "opb 19"
   
   // MARK: - Migration
   
   func nextVersion() -> CoreDataMigrationVersion? {
      switch self {
      case .v1: return .v2
      case .v2: return .v3
      case .v3: return .v4
      case .v4: return .v5
      case .v5: return .v6
      case .v6: return .v7
      case .v7: return .v8
      case .v8: return .v9
      case .v9: return .v10
      case .v10: return .v11
      case .v11: return .v12
      case .v12: return .v13
      case .v13: return .v14
      case .v14: return .v15
      case .v15: return .v16
      case .v16: return .v17
      case .v17: return .v18
      case .v18: return .v19
      case .v19: return nil
      }
   }
   
   // MARK: - Current
   
   static var current: CoreDataMigrationVersion {
      guard let latest = allCases.last else {
         fatalError("no model versions found")
      }
      
      return latest
   }
}
