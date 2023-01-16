//
//  FrequencySelection2.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 12/30/22.
//

import SwiftUI

struct FrequencySelection2: View {
   
   @Environment(\.colorScheme) var scheme
   
   @State private var segmentSelection: FreqSegment = .daily
   
   @State private var freqSelection: HabitFrequencyTest = .timesPerDay(1)
   
   @State private var weeklyFreqSelection: HabitFrequencyTest = .timesPerWeek(1)
   
   let segmentBgColor: Color = Color( #colorLiteral(red: 0.8901956677, green: 0.8901965022, blue: 0.9074040651, alpha: 1) )
   
   @State private var selectedWeekdays: [Int] = [1,5]
   
   @ObservedObject var vm = FrequencySelectionModel(selection: .timesPerDay(1))
   
   var body: some View {
      VStack(spacing: 20) {
         
         Picker("", selection: $segmentSelection) {
            ForEach(FreqSegment.allCases) { freq in
               Text(freq.rawValue.capitalized)
            }
         }
         .pickerStyle(.segmented)
         .padding(10)
         
         if segmentSelection == .daily {
            SelectableCard2Wrapper(selection: $freqSelection, type: .timesPerDay(1)) {
               EveryDaily2()
            }
            .transition(.move(edge: .leading))
         }
         
         if segmentSelection == .weekly {
            SelectableCard2Wrapper(selection: $weeklyFreqSelection, type: .timesPerWeek(1)) {
               XTimesPerWeekBeginningEveryY()
            }
            .transition(.move(edge: .trailing))
            
            SelectableCard2Wrapper(selection: $weeklyFreqSelection, type: .daysInTheWeek([0])) {
               EveryWeekOnSpecificWeekDays(selectedWeekdays: $selectedWeekdays)
                  .environmentObject(vm)
            }
            .transition(.move(edge: .trailing))
         }
         
         Spacer()
      }
      .animation(.easeInOut(duration: 0.2), value: segmentSelection)
   }
}

struct FrequencySelection2_Previews: PreviewProvider {
   static var previews: some View {
      VStack {
         Background {
            FrequencySelection2()
         }
      }
   }
}
