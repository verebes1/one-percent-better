//
//  EditHabitFrequency.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 8/28/22.
//

import SwiftUI

struct EditHabitFrequency: View {
   
   @Environment(\.managedObjectContext) var moc
   
   @EnvironmentObject var vm: ProgressViewModel
   @State private var selection: HabitFrequency
   
   init(habit: Habit) {
      let freq = habit.frequency(on: Date())
      self._selection = State(initialValue: freq ?? .timesPerDay(1))
   }
   
   var body: some View {
      Background {
         VStack(spacing: 20) {
            HabitCreationHeader(systemImage: "clock.arrow.2.circlepath",
                                title: "Frequency",
                                subtitle: "How often do you want to complete this habit?")
            
            FrequencySelectionStack(selection: $selection)
            
            Spacer()
         }
         .onDisappear {
            if selection != vm.habit.frequency(on: Date()) {
               vm.habit.changeFrequency(to: selection)
            }
         }
         .navigationBarTitleDisplayMode(.inline)
      }
   }
}

//struct EditHabitFrequency_Previews: PreviewProvider {
//   static var previews: some View {
//      NavigationView {
//         EditHabitFrequency(frequency: .timesPerDay(2))
//      }
//   }
//}
