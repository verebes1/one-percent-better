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
   
   var cancelBag = Set<AnyCancellable>()
   
   init() {
      $path
         .sink { path in
            print("new path: \(path)")
         }
         .store(in: &cancelBag)
   }
}

enum Tab {
   case habitList
   case settings
}

struct ContentView: View {
   @Environment(\.managedObjectContext) var moc
   
   @State private var tabSelection: Tab = .habitList
   
   /// Navigation path model
   @ObservedObject var nav = HabitTabNavPath()
   
   @ObservedObject var hlvm: HabitListViewModel
   
   @ObservedObject var hwvm: HeaderWeekViewModel
   
   init() {
      print("Initializing content view")
      let vm = HabitListViewModel(CoreDataManager.shared.mainContext)
      hlvm = vm
      hwvm = HeaderWeekViewModel(hlvm: vm)
   }
   
   var body: some View {
      let _ = Self._printChanges()
      return (
      TabView {
         NavigationStack(path: $nav.path) {
            HabitListView()
               .environmentObject(hlvm)
               .environmentObject(hwvm)
               .environmentObject(nav)
         }
         .tabItem {
            Label("Habits", systemImage: "checkmark.circle.fill")
         }
         
         NavigationStack {
            InsightsTabView()
               .environmentObject(hlvm)
               .environmentObject(hwvm)
         }
         .tabItem {
            Label("Insights", systemImage: "chart.bar.fill")
         }

         SettingsView()
            .tabItem {
               Label("Settings", systemImage: "gearshape.fill")
            }
      }
      )
   }
}

struct ContentView_Previews: PreviewProvider {
   
   static var previews: some View {
      let context = CoreDataManager.previews.mainContext
      ContentView()
         .environment(\.managedObjectContext, context)
   }
}
