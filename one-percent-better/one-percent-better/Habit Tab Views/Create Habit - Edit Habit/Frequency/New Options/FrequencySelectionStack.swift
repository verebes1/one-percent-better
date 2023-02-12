//
//  FrequencySelectionStack.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 12/30/22.
//

import SwiftUI

class FrequencySelectionModel: ObservableObject {
   
   @Published var selection: HabitFrequency
   
   init(selection: HabitFrequency) {
      self.selection = selection
   }
}

class TempFrequencySelectionModel: ObservableObject {
   
}

enum FreqSegment: String, Identifiable, CaseIterable {
   case daily
   case weekly
//   case monthly
   var id: Self { self }
}

struct FrequencySelectionStack: View {
   
   @Environment(\.colorScheme) var scheme
   
   @EnvironmentObject var vm: FrequencySelectionModel
   
   @State private var segmentSelection: FreqSegment = .daily
   
   @State private var dailyFreqSelection: HabitFrequency = .timesPerDay(1)
   
   @State private var weeklyFreqSelection: HabitFrequency = .daysInTheWeek([1, 5])
   
   @State private var timesPerDay: Int = 1
   @State private var everyXDays: Int = 2
   @State private var daysPerWeek: [Int] = [1,5]
   @State private var timesPerWeek: (times: Int, resetDay: Weekday) = (times: 1, resetDay: .sunday)
   
   init(vm: FrequencySelectionModel) {
      switch vm.selection {
      case .timesPerDay(let n):
         self._timesPerDay = State(initialValue: n)
//      case .everyXDays(let n):
//         self._everyXDays = State(initialValue: n)
      case .daysInTheWeek(let days):
         self._daysPerWeek = State(initialValue: days)
      case .timesPerWeek(times: let times, resetDay: let resetDay):
         self._timesPerWeek = State(initialValue: (times, resetDay))
      }
   }
   
   var body: some View {
      VStack(spacing: 20) {
         
         Picker("", selection: $segmentSelection) {
            ForEach(FreqSegment.allCases) { freq in
               Text(freq.rawValue.capitalized)
            }
         }
         .pickerStyle(.segmented)
         .padding(.horizontal, 10)
         .padding(.bottom, 7)
         
         if segmentSelection == .daily {
            SelectableFrequencyCard(selection: $dailyFreqSelection, type: .timesPerDay(1)) {
               EveryDayXTimesPerDay(timesPerDay: $timesPerDay)
                  .onChange(of: timesPerDay) { newValue in
                     vm.selection = .timesPerDay(timesPerDay)
                  }
            } onSelection: {
               dailyFreqSelection = .timesPerDay(timesPerDay)
               vm.selection = .timesPerDay(timesPerDay)
            }
            .transition(.move(edge: .leading))
         }
         
         if segmentSelection == .weekly {
            SelectableFrequencyCard(selection: $weeklyFreqSelection, type: .daysInTheWeek([0])) {
               EveryWeekOnSpecificWeekDays(selectedWeekdays: $daysPerWeek)
                  .onChange(of: daysPerWeek) { newValue in
                     vm.selection = .daysInTheWeek(daysPerWeek)
                  }
                  .environmentObject(vm)
            } onSelection: {
               weeklyFreqSelection = .daysInTheWeek(daysPerWeek)
               vm.selection = .daysInTheWeek(daysPerWeek)
            }
            .transition(.move(edge: .trailing))
            
            SelectableFrequencyCard(selection: $weeklyFreqSelection, type: .timesPerWeek(times: 1, resetDay: .sunday)) {
               XTimesPerWeekBeginningEveryY()
            } onSelection: {
               weeklyFreqSelection = .timesPerWeek(times: timesPerWeek.times, resetDay: timesPerWeek.resetDay)
               vm.selection = .timesPerWeek(times: timesPerWeek.times, resetDay: timesPerWeek.resetDay)
            }
            .transition(.move(edge: .trailing))
         }
         
//         Text("More frequency options coming soon!")
//            .padding(.top, 10)
//            .foregroundColor(.secondaryLabel)
         
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
            FrequencySelectionStack(vm: vm)
               .environmentObject(vm)
         }
      }
   }
}
