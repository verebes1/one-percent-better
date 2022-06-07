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
        HabitListView(viewModel: HabitListViewModel(moc))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
