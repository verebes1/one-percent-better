//
//  SettingsController.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/20/22.
//

import Foundation
import CoreData

class SettingsController {
   
   static var shared = SettingsController()
   
   var settings: Settings!
   
   var context = CoreDataManager.shared.mainContext
   
   init() {
      var settings: [Settings] = []
      do {
         // fetch settings
         let fetchRequest: NSFetchRequest<Settings> = Settings.fetchRequest()
         settings = try context.fetch(fetchRequest)
      } catch {
         fatalError("\(#file) \(#function) - unable to fetch settings! Error: \(error)")
      }
      
      if settings.isEmpty {
         self.settings = Settings(myContext: context)
      } else if settings.count == 1 {
         self.settings = settings[0]
      } else {
         fatalError("Too many settings entities")
      }
   }
   
   func updateDailyReminder(to enabled: Bool) {
      self.settings.dailyReminderEnabled = enabled
   }
   
   func updateDailyReminder(time: Date) {
      self.settings.dailyReminderTime = time
   }
}
