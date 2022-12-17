//
//  HabitFrequencyStack.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 9/28/22.
//

import SwiftUI

class FrequencySelectionModel: ObservableObject {
   
   @Published var selection: HabitFrequency
   
   init(selection: HabitFrequency) {
      self.selection = selection
   }
}

struct FrequencySelectionStack: View {
   
   @EnvironmentObject var vm: FrequencySelectionModel
   
   @State private var timesPerDay: Int = 1
   @State private var daysPerWeek: [Int] = [2,4]
   
   init(vm: FrequencySelectionModel) {
      switch vm.selection {
      case .timesPerDay(let n):
         self._timesPerDay = State(initialValue: n)
      case .daysInTheWeek(let days):
         self._daysPerWeek = State(initialValue: days)
      }
   }
   
   var body: some View {
      VStack(spacing: 20) {
         SelectableCard(selection: $vm.selection, type: .timesPerDay(1)) {
            EveryDaily(timesPerDay: $timesPerDay)
         } onSelection: {
            vm.selection = .timesPerDay(timesPerDay)
         }
         
         SelectableCard(selection: $vm.selection, type: .daysInTheWeek([0])) {
            EveryWeekly(selectedWeekdays: $daysPerWeek)
         } onSelection: {
            vm.selection = .daysInTheWeek(daysPerWeek)
         }
         
         SelectableCard(selection: $vm.selection, type: .daysInTheWeek([0])) {
            EveryXTimesPerY(timesPerDay: $timesPerDay)
         } onSelection: {
            vm.selection = .daysInTheWeek(daysPerWeek)
         }
      }
   }
}

struct HabitFrequencyStack_Previews: PreviewProvider {
   static var previews: some View {
      let vm = FrequencySelectionModel(selection: .timesPerDay(1))
      Background {
         FrequencySelectionStack(vm: vm)
            .environmentObject(vm)
      }
   }
}
