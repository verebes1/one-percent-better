//
//  OnePercentBetterApp.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/15/22.
//

import SwiftUI

@main
struct OnePercentBetterApp: App {
   
   @StateObject private var coreDataManager = CoreDataManager.shared
   
   var body: some Scene {
      WindowGroup {
         ContentView()
            .environment(\.managedObjectContext, coreDataManager.mainContext)
            .onAppear {
               print("NSHomeDirectory: \(NSHomeDirectory())")
               FeatureLogController.shared.setUp()
               NotificationManager.shared.rebalanceHabitNotifications()
            }
      }
   }
}
