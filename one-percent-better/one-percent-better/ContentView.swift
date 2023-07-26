//
//  ContentView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/15/22.
//

import SwiftUI
import Combine
import CoreData

class HabitTabNavPath: ObservableObject {
   @Published var path = NavigationPath()
}

class BottomBarManager: ObservableObject {
   @Published var isHidden = false
}

class SettingsViewModel: ConditionalManagedObjectFetcher<Settings> {
   
   @Published var settings: [Settings] = []
   
   init(_ context: NSManagedObjectContext = CoreDataManager.shared.mainContext) {
      super.init(context, sortDescriptors: [])
      settings = fetchedObjects
   }
   
   override func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
      settings = controller.fetchedObjects as? [Settings] ?? []
   }
}

struct ContentView: View {
   @Environment(\.managedObjectContext) var moc

   enum Tabs: String {
      case habitList
      case insights
      case settings
   }
   
   @SceneStorage("ContentView.selectedTab") private var selectedTab = Tabs.habitList
   
   @StateObject var nav = HabitTabNavPath()
   @StateObject var barManager = BottomBarManager()
   @StateObject var hlvm = HabitListViewModel()
   @StateObject var hsvm = HeaderSelectionViewModel(hwvm: HeaderWeekViewModel())
   @StateObject var svm = SettingsViewModel()
   
   init(_ context: NSManagedObjectContext = CoreDataManager.shared.mainContext) {
      self._hlvm = StateObject(wrappedValue: HabitListViewModel(context))
   }
   
   var body: some View {
      TabView(selection: $selectedTab) {
         // Habits
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
         
         // Insights
         NavigationStack {
            InsightsTabView()
               .environmentObject(hlvm)
         }
         .tabItem {
            Label("Insights", systemImage: "chart.line.uptrend.xyaxis")
         }
         .tag(Tabs.insights)

         // Settings
         NavigationStack {
            SettingsView()
         }
         .tabItem {
            Label("Settings", systemImage: "gearshape.fill")
         }
         .tag(Tabs.settings)
      }
      .preferredColorScheme(svm.settings.first?.appearanceScheme)
   }
}

struct ContentView_Previews: PreviewProvider {
   static let h0id = UUID()
   static let h1id = UUID()
   static let h2id = UUID()
   
   static func data() {
      let context = CoreDataManager.previews.mainContext
      
      let _ = try? Habit(context: context, name: "Never completed", id: HabitsViewPreviewer.h0id)
      
      let h1 = try? Habit(context: context, name: "Completed yesterday", id: HabitsViewPreviewer.h1id)
      let yesterday = Cal.date(byAdding: .day, value: -1, to: Date())!
      h1?.markCompleted(on: yesterday)
      
      let h2 = try? Habit(context: context, name: "Completed today", id: HabitsViewPreviewer.h2id)
      h2?.markCompleted(on: Date())
      
      context.assertSave()
   }
   
   static var previews: some View {
      let context = CoreDataManager.previews.mainContext
      let _ = data()
      ContentView(context)
         .environment(\.managedObjectContext, context)
   }
}
