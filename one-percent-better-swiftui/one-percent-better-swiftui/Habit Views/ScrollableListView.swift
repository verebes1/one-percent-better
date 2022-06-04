//
//  ScrollableListView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/3/22.
//

import SwiftUI

struct ScrollableListView: View {
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(sortDescriptors: [
        NSSortDescriptor(keyPath: \Habit.orderIndex, ascending: true)
    ]) var habits: FetchedResults<Habit>
    
    var body: some View {
        NavigationView {
            Background {
                TabView {
                    VStack {
                        Text("Date:")
                        List {
                            ForEach(habits, id: \.self.name) { habit in
                                NavigationLink(
                                    destination: ProgressView().environmentObject(habit)) {
                                        HabitRow()
                                            .environmentObject(habit)
                                    }
                            }
                        }
                    }
                    
                    VStack {
                        Text("Date:")
                        List {
                            ForEach(habits, id: \.self.name) { habit in
                                NavigationLink(
                                    destination: ProgressView().environmentObject(habit)) {
                                        HabitRow()
                                            .environmentObject(habit)
                                    }
                            }
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Habits")
        }
    }
}

struct ScrollableListView_Previews: PreviewProvider {
    static var previews: some View {
        
        PreviewData.habitViewData()
        
        return ScrollableListView()
            .environment(\.managedObjectContext, CoreDataManager.previews.persistentContainer.viewContext)
        
    }
}
