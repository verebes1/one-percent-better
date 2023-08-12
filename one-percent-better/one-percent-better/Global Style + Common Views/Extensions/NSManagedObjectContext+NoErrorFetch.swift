//
//  NSManagedContext+NoErrorFetch.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 3/31/23.
//

import Foundation
import CoreData

protocol HasFetchRequest {
    static func fetchRequest<T>() -> NSFetchRequest<T>
}

extension NSManagedObjectContext {
    
    func fetchArray<T: HasFetchRequest>(_ type: T.Type) -> [T] {
        var entities: [T] = []
        do {
            guard let results = try self.fetch(type.fetchRequest()) as? [T] else {
                assertionFailure("Unable to cast entity \(String(describing: type))")
                return []
            }
            entities = results
        } catch {
            assertionFailure("Unable to fetch entity \(String(describing: type))! Error: \(error)")
            return []
        }
        return entities
    }
    
    func fetchFirst<T: HasFetchRequest>(_ type: T.Type) -> T? {
        return self.fetchArray(type).first
    }
}
