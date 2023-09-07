//
//  StartOfWeekModel.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 9/7/23.
//

import Foundation
import CoreData

/// A model for observing changes in the start of the week setting
class StartOfWeekModel: ConditionalManagedObjectFetcher<Settings> {
    
    @Published var startOfWeek: Weekday = .monday
    
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
