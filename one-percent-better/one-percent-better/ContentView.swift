//
//  ContentView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/15/22.
//

import SwiftUI

class HabitTabNavPath: ObservableObject {
   @Published var path = NavigationPath()
}

enum Tab {
   case habitList
   case settings
}

struct ContentView: View {
   @Environment(\.managedObjectContext) var moc
   
   @State private var tabSelection: Tab = .habitList
   
   var body: some View {
      
//      MyTabView(selection: $tabSelection) {
//
//      }
      
      TabView {
         HabitListView(vm: HabitListViewModel(moc))
            .environmentObject(HabitTabNavPath())
            .tabItem {
               Label("Habits", systemImage: "checkmark.circle.fill")
            }

         SettingsView(vm: SettingsViewModel(moc))
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
