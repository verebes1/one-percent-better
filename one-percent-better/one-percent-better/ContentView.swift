//
//  ContentView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/15/22.
//

import SwiftUI
import Combine

class HabitTabNavPath: ObservableObject {
   static var shared = HabitTabNavPath()
   
   @Published var path = NavigationPath()
   
   var cancelBag = Set<AnyCancellable>()
   
   init() {
      $path
         .sink { path in
            print("new path: \(path)")
         }
         .store(in: &cancelBag)
   }
}

enum Tab: Equatable {
   case habitList
   case settings
}

struct ContentView: View {
   @Environment(\.managedObjectContext) var moc
   
   @State private var tabSelection: Tab = .habitList
   
   @ObservedObject var nav = HabitTabNavPath.shared
   @ObservedObject var hlvm = HabitListViewModel()
   @ObservedObject var hsvm = HeaderSelectionViewModel(hwvm: HeaderWeekViewModel())
   
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
         .tabItem {
            Label("Habits", systemImage: "checkmark.circle.fill")
         }
         
         NavigationStack {
            InsightsTabView()
               .environmentObject(hlvm)
         }
         .tabItem {
            Label("Insights", systemImage: "chart.bar.fill")
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
