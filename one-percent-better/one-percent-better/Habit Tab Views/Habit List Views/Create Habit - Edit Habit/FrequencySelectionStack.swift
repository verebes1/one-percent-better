//
//  HabitFrequencyStack.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 9/28/22.
//

import SwiftUI

class FrequencySelectionModel: ObservableObject {
   
   @Published var selection: HabitFrequency = .timesPerDay(1)
   @Published var timesPerDay: Int = 1
   @Published var daysPerWeek: [Int] = [2,4]
   
   init(selection: HabitFrequency) {
      self.selection = selection
      switch selection {
      case .timesPerDay(let n):
         self.timesPerDay = n
      case .daysInTheWeek(let days):
         self.daysPerWeek = days
      }
   }
}

struct FrequencySelectionStack: View {
   
   @EnvironmentObject var vm: FrequencySelectionModel
   
   var body: some View {
      VStack(spacing: 20) {
         SelectableCard(selection: $vm.selection, type: .timesPerDay(vm.timesPerDay)) {
            EveryDaily(timesPerDay: $vm.timesPerDay)
         }
         
         SelectableCard(selection: $vm.selection, type: .daysInTheWeek(vm.daysPerWeek)) {
            EveryWeekly(selectedWeekdays: $vm.daysPerWeek)
         }
      }
   }
}

struct HabitFrequencyStack_Previews: PreviewProvider {
   static var previews: some View {
      let vm = FrequencySelectionModel(selection: .timesPerDay(1))
      Background {
         FrequencySelectionStack()
            .environmentObject(vm)
      }
   }
}
