//
//  EditHabitFrequency.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 8/28/22.
//

import SwiftUI

struct EditHabitFrequency: View {
   
   @Environment(\.managedObjectContext) var moc
   
   @EnvironmentObject var habit: Habit
   
   @ObservedObject var vm: FrequencySelectionModel
   
   init(frequency: HabitFrequency) {
      self.vm = FrequencySelectionModel(selection: frequency)
   }
   
   var body: some View {
      Background {
         VStack(spacing: 20) {
            HabitCreationHeader(systemImage: "clock.arrow.2.circlepath",
                                title: "Frequency",
                                subtitle: "How often do you want to complete this habit?")
            
//            FrequencySelectionStack(vm: vm)
//               .environmentObject(vm)
            
            FrequencySelectionStack2(vm: vm)
               .environmentObject(vm)
            
            Spacer()
         }
         .onDisappear {
            if vm.selection != habit.frequency(on: Date()) {
               habit.changeFrequency(to: vm.selection)
            }
         }
         .navigationBarTitleDisplayMode(.inline)
      }
   }
}

struct EditHabitFrequency_Previews: PreviewProvider {
   static var previews: some View {
      NavigationView {
         EditHabitFrequency(frequency: .timesPerDay(2))
      }
   }
}
