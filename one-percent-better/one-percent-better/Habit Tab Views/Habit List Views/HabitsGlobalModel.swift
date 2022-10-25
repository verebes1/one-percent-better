//
//  HabitsGlobalModel.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/24/22.
//

import SwiftUI
import CoreData
import Combine

class HabitsGlobalModel: NSObject, NSFetchedResultsControllerDelegate, ObservableObject {
   
   
   static let shared = HabitsGlobalModel(CoreDataManager.shared.mainContext)
   
   private let habitController: NSFetchedResultsController<Habit>
   private let moc: NSManagedObjectContext
   
   /// The latest day that has been shown. This is updated when the
   /// app is opened or the view appears on a new day.
   @Published var latestDay: Date = Date()
   
   /// Which day is selected in the HabitHeaderView
   @Published var selectedWeekDay: Int = 0
   
   /// Which week is selected in the HabitHeaderView
   @Published var selectedWeek: Int = 0
   
   @Published var currentDay: Date = Date()
   
   
   
   init(_ context: NSManagedObjectContext) {
      let sortDescriptors = [NSSortDescriptor(keyPath: \Habit.orderIndex, ascending: true)]
      habitController = Habit.resultsController(context: context, sortDescriptors: sortDescriptors)
      moc = context
      super.init()
      habitController.delegate = self
      try? habitController.performFetch()
   }
   
   func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
      objectWillChange.send()
   }
   
   var habits: [Habit] {
      return habitController.fetchedObjects ?? []
   }
   
   func trackers(for habit: Habit) -> [Tracker] {
      habit.trackers.map { $0 as! Tracker }
   }
   
}
