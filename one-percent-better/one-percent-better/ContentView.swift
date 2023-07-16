//
//  ContentView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/15/22.
//

import SwiftUI
import Combine

class HabitTabNavPath: ObservableObject {
   @Published var path = NavigationPath()
}

class BottomBarManager: ObservableObject {
   @Published var isHidden = false
}

struct ContentView: View {
   @Environment(\.managedObjectContext) var moc

   enum Tabs: String {
      case habitList
      case insights
      case settings
   }
   
   @SceneStorage("ContentView.selectedTab") private var selectedTab = Tabs.habitList

   @FetchRequest(entity: Settings.entity(), sortDescriptors: []) private var settings: FetchedResults<Settings>
   
   @StateObject var nav = HabitTabNavPath()
   @StateObject var barManager = BottomBarManager()
   @StateObject var hlvm = HabitListViewModel()
   @StateObject var hsvm = HeaderSelectionViewModel(hwvm: HeaderWeekViewModel())
   
   var body: some View {
      TabView(selection: $selectedTab) {
         NavigationStack(path: $nav.path) {
            HabitListViewContainer()
               .environmentObject(hlvm)
               .environmentObject(hsvm)
         }
         .environmentObject(nav)
         .environmentObject(barManager)
         .tabItem {
            Label("Habits", image: "custom.bolt.ring.closed")
         }
         .tag(Tabs.habitList)
         
         NavigationStack {
            InsightsTabView()
               .environmentObject(hlvm)
         }
         .tabItem {
            Label("Insights", systemImage: "chart.line.uptrend.xyaxis")
         }
         .tag(Tabs.insights)

         SettingsView()
            .tabItem {
               Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(Tabs.settings)
      }
      .onAppear {
         print("NSHomeDirectory: \(NSHomeDirectory())")
         FeatureLogController.shared.setUp()
         NotificationManager.shared.rebalanceHabitNotifications()
      }
      .preferredColorScheme(settings.first?.appearanceScheme)
   }
}

struct ContentView_Previews: PreviewProvider {
   
   static var previews: some View {
      let context = CoreDataManager.previews.mainContext
      ContentView()
         .environment(\.managedObjectContext, context)
   }
}
