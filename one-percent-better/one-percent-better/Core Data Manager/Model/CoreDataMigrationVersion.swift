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
    
    // MARK: - Current
    
    static var current: CoreDataMigrationVersion {
        guard let latest = allCases.last else {
            fatalError("no model versions found")
        }
        
        return latest
    }
    
    // MARK: - Migration
    
    func nextVersion() -> CoreDataMigrationVersion? {
        switch self {
        case .v1:
            return .v2
        case .v2:
            return .v3
        case .v3:
            return .v4
        case .v4:
            return .v5
        case .v5:
            return .v6
        case .v6:
            return .v7
        case .v7:
            return nil
        }
    }
}
