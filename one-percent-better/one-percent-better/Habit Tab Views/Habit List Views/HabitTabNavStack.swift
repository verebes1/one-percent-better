//
//  HabitTabNavStack.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/30/22.
//

import SwiftUI

struct HabitTabNavStack: View {
   
   @Environment(\.managedObjectContext) var moc
   
   /// Navigation path model
   @StateObject var nav = HabitTabNavPath()
   
   var body: some View {
      NavigationStack(path: $nav.path) {
         HabitListView(vm: HabitListViewModel(moc))
            .environmentObject(nav)
            .navigationViewStyle(StackNavigationViewStyle())
            .toolbarBackground(Color.backgroundColor, for: .tabBar)
      }
   }
}

struct HabitTabNavStack_Previews: PreviewProvider {
   static var previews: some View {
      let context = CoreDataManager.previews.mainContext
      HabitTabNavStack()
         .environment(\.managedObjectContext, context)
   }
}
