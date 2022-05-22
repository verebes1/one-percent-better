//
//  PreviewData.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/21/22.
//

import Foundation
import CoreData

class PreviewData {
    
    static func habitViewData() {
        let context = CoreDataManager.previews.persistentContainer.viewContext
        CoreDataManager.resetPreviewsData()
        
        let _ = Habit(context: context, name: "Never completed")
        
        let h1 = Habit(context: context, name: "Completed yesterday")
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        h1.markCompleted(on: yesterday, save: false)
        
        let h2 = Habit(context: context, name: "Completed today")
        h2.markCompleted(on: Date(), save: false)
    }
}
