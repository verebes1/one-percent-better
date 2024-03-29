//
//  CoreDataManager.swift
//  CoreDataMigration-Example
//
//  Created by William Boles on 11/09/2017.
//  Copyright © 2017 William Boles. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager: ObservableObject {
   
   let migrator: CoreDataMigratorProtocol
   private let storeType: String
   
   /// This class is used to fix the error: "Multiple NSEntityDescriptions Claim NSManagedObject Subclass"
   /// when trying to load the persistent container in memory during testing. It loads the mom file only once
   class PersistentContainer {
      private static var _model: NSManagedObjectModel?
      private static func model(name: String) throws -> NSManagedObjectModel {
         if _model == nil {
            _model = try loadModel(name: name, bundle: Bundle.main)
         }
         return _model!
      }
      private static func loadModel(name: String, bundle: Bundle) throws -> NSManagedObjectModel {
         guard let modelURL = bundle.url(forResource: name, withExtension: "momd") else {
            throw CoreDataError.modelURLNotFound(forResourceName: name)
         }
         
         guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            throw CoreDataError.modelLoadingFailed(forURL: modelURL)
         }
         return model
      }
      
      enum CoreDataError: Error {
         case modelURLNotFound(forResourceName: String)
         case modelLoadingFailed(forURL: URL)
      }
      
      public static func container() throws -> NSPersistentContainer {
         let name = "mo_ikai"
         return NSPersistentContainer(name: name, managedObjectModel: try model(name: name))
      }
   }
   
   lazy var persistentContainer: NSPersistentContainer = {
      let persistentContainer = try! PersistentContainer.container()
      guard let description = persistentContainer.persistentStoreDescriptions.first else {
         preconditionFailure("Can't find presistentContainer's store descriptions")
      }
      description.shouldInferMappingModelAutomatically = false //inferred mapping will be handled else where
      description.shouldMigrateStoreAutomatically = false
      description.type = storeType
      return persistentContainer
   }()
   
   lazy var backgroundContext: NSManagedObjectContext = {
       let context = NSManagedObjectContext(.privateQueue)
       //      context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
       context.parent = mainContext
       context.automaticallyMergesChangesFromParent = true
       return context
   }()
   
   lazy var mainContext: NSManagedObjectContext = {
      let context = self.persistentContainer.viewContext
      context.automaticallyMergesChangesFromParent = true
      return context
   }()
   
   // MARK: - Actual data singleton
   
   static let shared = CoreDataManager()
   
   
   // MARK: - Init
   
   init(storeType: String = NSSQLiteStoreType, migrator: CoreDataMigratorProtocol = CoreDataMigrator(), inMemory: Bool = false) {
      self.storeType = storeType
      self.migrator = migrator
      
      if inMemory {
         persistentContainer.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
         persistentContainer.persistentStoreDescriptions.first!.type = NSInMemoryStoreType
      }
      
      loadPersistentStore()
   }
   
   // MARK: - Loading
   
   private func loadPersistentStore() {
      migrateStoreIfNeeded {
         self.persistentContainer.loadPersistentStores { description, error in
            guard error == nil else {
               fatalError("was unable to load store \(error!)")
            }
         }
      }
   }
   
   private func migrateStoreIfNeeded(completion: @escaping () -> Void) {
      guard let storeURL = persistentContainer.persistentStoreDescriptions.first?.url else {
         preconditionFailure("persistentContainer was not set up properly")
      }
      if migrator.requiresMigration(at: storeURL, toVersion: CoreDataMigrationVersion.current) {
         self.migrator.migrateStore(at: storeURL, toVersion: CoreDataMigrationVersion.current)
      }
      completion()
   }
   
   // MARK: - Saving
   
   func saveContext() {
      if mainContext.hasChanges {
         do {
            try mainContext.save()
         } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
         }
      }
   }
   
   // MARK: - Previews
   
   static let previews = CoreDataManager(inMemory: true)
   
   static func resetPreviewsData() {
      let context = Self.previews.persistentContainer.viewContext
      let fetchedHabits = Habit.habits(from: context)
      for habit in fetchedHabits {
         context.delete(habit)
      }
   }
}

extension NSManagedObjectContext {
   
   func assertSave() {
      if self.hasChanges {
         do {
            try self.save()
         } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            assert(false, "Unresolved error \(nserror), \(nserror.userInfo)")
            //            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
         }
      }
   }
}
