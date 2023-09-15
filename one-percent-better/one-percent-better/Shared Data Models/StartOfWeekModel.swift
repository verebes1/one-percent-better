//
//  StartOfWeekModel.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 9/7/23.
//

import Foundation
import CoreData
import Combine

/// A model for observing changes in the start of the week setting
class StartOfWeekModel: ConditionalManagedObjectFetcher<Settings> {
    
    static let shared = StartOfWeekModel(CoreDataManager.shared.mainContext)
    
    private var _startOfWeek: Weekday = .monday
    var startOfWeek: Weekday {
        get {
            return _startOfWeek
        }
        set {
            _startOfWeek = newValue
            startOfWeekSubject.send(newValue)
        }
    }
    
    /// Use a passthrough subject so that subscribers are notified AFTER the startOfWeek value changes,
    /// so that we can use the singleton to get the most recent update
    let startOfWeekSubject = PassthroughSubject<Weekday, Never>()
    
    init(_ context: NSManagedObjectContext = CoreDataManager.shared.mainContext) {
        super.init(context)
        guard let settings = fetchedObjects.first else { return }
        startOfWeek = settings.startOfWeek
    }
    
    override func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let newSettings = controller.fetchedObjects?.first as? Settings else { return }
        let newStartOfWeek = newSettings.startOfWeek
        if newStartOfWeek != startOfWeek {
            startOfWeek = newStartOfWeek
        }
    }
}
