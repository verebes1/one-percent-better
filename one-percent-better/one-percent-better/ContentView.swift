//
//  ContentView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/15/22.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        TabView {
            HabitListView(vm: HabitListViewModel(moc))
                .tabItem {
                    Label("Habits", systemImage: "checkmark.circle.fill")
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
