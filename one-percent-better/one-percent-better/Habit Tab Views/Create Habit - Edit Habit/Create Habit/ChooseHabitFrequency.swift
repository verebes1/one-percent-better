//
//  ChooseHabitFrequency.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 8/9/22.
//

import SwiftUI

enum HabitFrequencyError: Error {
   case zeroFrequency
   case emptyFrequency
}

struct ChooseHabitFrequency: View {
   
   @Environment(\.managedObjectContext) var moc
   
   @EnvironmentObject var nav: HabitTabNavPath
   
   var habitName: String
   
   @ObservedObject var vm = FrequencySelectionModel(selection: .timesPerDay(1))
   
   @Binding var hideTabBar: Bool
   
   var body: some View {
      Background {
         VStack {
            Spacer()
               .frame(height: 20)
            HabitCreationHeader(systemImage: "clock.arrow.2.circlepath",
                                title: "Frequency",
                                subtitle: "How often do you want to complete this habit?")
            
//            Spacer().frame(height: 20)
            
            FrequencySelectionStack(vm: vm)
               .environmentObject(vm)
            
            Spacer()
            
            BottomButton(label: "Finish")
               .onTapGesture {
                  let _ = try? Habit(context: moc,
                                     name: habitName,
                                     frequency: vm.selection)
                  hideTabBar = false
                  nav.path.removeLast(2)
               }
         }
         .toolbar(.hidden, for: .tabBar)
      }
   }
}

struct HabitFrequency_Previews: PreviewProvider {
   static var previews: some View {
      ChooseHabitFrequency(habitName: "Horseback Riding", hideTabBar: .constant(true))
   }
}
