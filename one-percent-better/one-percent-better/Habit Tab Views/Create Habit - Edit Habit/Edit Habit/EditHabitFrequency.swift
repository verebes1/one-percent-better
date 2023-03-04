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
   
   @State private var selection: HabitFrequency
   
   init(frequency: HabitFrequency) {
      self._selection = State(initialValue: frequency)
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
            if selection != habit.frequency(on: Date()) {
               habit.changeFrequency(to: selection)
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
