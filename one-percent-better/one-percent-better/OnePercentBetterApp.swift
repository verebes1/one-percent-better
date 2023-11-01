//
//  OnePercentBetterApp.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/15/22.
//

import SwiftUI

@main
struct OnePercentBetterApp: App {
    
    private var coreDataManager = CoreDataManager.shared
    
    var body: some Scene {
        WindowGroup {
            if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil {
                // Regular app behavior
                ContentView()
                    .environment(\.managedObjectContext, coreDataManager.mainContext)
                    .onAppear {
                        print("NSHomeDirectory: \(NSHomeDirectory())")
                        print("Device UDID: \(String(describing: UIDevice.current.identifierForVendor?.uuidString))")
                        FeatureLogController.shared.setUp()
                        NotificationManager.shared.rebalance()
                    }
            } else {
                // App behavior during testing
                EmptyView()
            }   
        }
    }
}
