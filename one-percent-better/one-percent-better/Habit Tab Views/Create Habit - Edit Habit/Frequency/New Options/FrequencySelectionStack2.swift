//
//  FrequencySelectionStack2.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 12/30/22.
//

import SwiftUI

struct FrequencySelectionStack2: View {
   
   @Environment(\.colorScheme) var scheme
   
   @EnvironmentObject var vm: FrequencySelectionModel
   
   @State private var segmentSelection: FreqSegment = .daily
   
//   @State private var freqSelection: HabitFrequencyTest = .timesPerDay(1)
   
//   @State private var dailyFreqSelection
   
//   @State private var weeklyFreqSelection: HabitFrequencyTest = .timesPerWeek(1)
   
   @State private var timesPerDay: Int = 1
   @State private var daysPerWeek: [Int] = [1,5]
   
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
         
//         Picker("", selection: $segmentSelection) {
//            ForEach(FreqSegment.allCases) { freq in
//               Text(freq.rawValue.capitalized)
//            }
//         }
//         .pickerStyle(.segmented)
//         .padding(10)
         
//         if segmentSelection == .daily {
            SelectableCard2Wrapper(selection: $vm.selection, type: .timesPerDay(1)) {
               EveryDayXTimesPerDay(timesPerDay: $timesPerDay)
            }
            .transition(.move(edge: .leading))
//         }
         
//         if segmentSelection == .weekly {
            SelectableCard2Wrapper(selection: $vm.selection, type: .daysInTheWeek([0])) {
               EveryWeekOnSpecificWeekDays(selectedWeekdays: $daysPerWeek)
                  .environmentObject(vm)
            }
            .transition(.move(edge: .trailing))
            
//            SelectableCard2Wrapper(selection: $weeklyFreqSelection, type: .timesPerWeek(1)) {
//               XTimesPerWeekBeginningEveryY()
//            }
//            .transition(.move(edge: .trailing))
//         }
         
         Text("More frequency options coming soon!")
            .padding(.top, 10)
            .foregroundColor(.secondaryLabel)
         
         Spacer()
      }
      .animation(.easeInOut(duration: 0.2), value: segmentSelection)
   }
}

struct FrequencySelection2_Previews: PreviewProvider {
   static var previews: some View {
      let vm = FrequencySelectionModel(selection: .timesPerDay(1))
      VStack {
         Background {
            FrequencySelectionStack2(vm: vm)
               .environmentObject(vm)
         }
      }
   }
}
