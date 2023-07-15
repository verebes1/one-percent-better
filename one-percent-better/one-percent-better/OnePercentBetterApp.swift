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
   @AppStorage("selectedAppearance") var selectedAppearance = 0
   
   var body: some Scene {
      WindowGroup {
         ContentView()
            .environment(\.managedObjectContext, coreDataManager.mainContext)
            .preferredColorScheme(selectedAppearance == 1 ? .light : selectedAppearance == 2 ? .dark : nil)
            .onAppear {
               print("NSHomeDirectory: \(NSHomeDirectory())")
               FeatureLogController.shared.setUp()
               NotificationManager.shared.rebalanceHabitNotifications()
            }
      }
   }
}
