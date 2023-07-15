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

enum Tab: Equatable {
   case habitList
   case settings
}

struct ContentView: View {
   @Environment(\.managedObjectContext) var moc
   
   @State private var tabSelection: Tab = .habitList
   
   @StateObject var nav = HabitTabNavPath()
   @StateObject var barManager = BottomBarManager()
   @StateObject var hlvm = HabitListViewModel()
   @StateObject var hsvm = HeaderSelectionViewModel(hwvm: HeaderWeekViewModel())
   
   init() {
      print("Initializing content view")
   }
   
   var body: some View {
      let _ = Self._printChanges()
      TabView(selection: $tabSelection) {
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
         
         NavigationStack {
            InsightsTabView()
               .environmentObject(hlvm)
         }
         .tabItem {
            Label("Insights", systemImage: "chart.line.uptrend.xyaxis")
         }

         SettingsView()
            .tabItem {
               Label("Settings", systemImage: "gearshape.fill")
            }
      }
   }
}

struct ContentView_Previews: PreviewProvider {
   
   static var previews: some View {
      let context = CoreDataManager.previews.mainContext
      ContentView()
         .environment(\.managedObjectContext, context)
   }
}
