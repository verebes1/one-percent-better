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

enum FreqSegment: String, Identifiable, CaseIterable {
   case daily
   case weekly
//   case monthly
   var id: Self { self }
}

struct FrequencySelectionStack: View {
   
   @Environment(\.colorScheme) var scheme
   
   @Binding var selection: HabitFrequency
   
   @State private var segmentSelection: FreqSegment
   
   @State private var dailyFreqSelection: HabitFrequency
   
   @State private var weeklyFreqSelection: HabitFrequency
   
   @State private var timesPerDay: Int = 1
   @State private var everyXDays: Int = 2
   @State private var daysPerWeek: [Weekday] = [.monday, .friday]
   @State private var timesPerWeek: (times: Int, resetDay: Weekday) = (times: 1, resetDay: .sunday)
   
   init(selection: Binding<HabitFrequency>) {
      self._selection = selection
      self._dailyFreqSelection = State(initialValue: .timesPerDay(1))
      self._weeklyFreqSelection = State(initialValue: .specificWeekdays([.monday, .friday]))
      
      switch selection.wrappedValue {
      case .timesPerDay(let n):
         self._timesPerDay = State(initialValue: n)
         self._segmentSelection = State(initialValue: .daily)
         self._dailyFreqSelection = State(initialValue: .timesPerDay(n))
      case .specificWeekdays(let days):
         self._daysPerWeek = State(initialValue: days)
         self._segmentSelection = State(initialValue: .weekly)
         self._weeklyFreqSelection = State(initialValue: .specificWeekdays(days))
      case .timesPerWeek(times: let times, resetDay: let resetDay):
         self._timesPerWeek = State(initialValue: (times, resetDay))
         self._segmentSelection = State(initialValue: .weekly)
         self._weeklyFreqSelection = State(initialValue: .timesPerWeek(times: times, resetDay: resetDay))
      }
   }
   
   func changeFrequency(to freq: HabitFrequency) {
      switch freq {
      case .timesPerDay(let n):
         dailyFreqSelection = .timesPerDay(n)
         selection = .timesPerDay(n)
      case .specificWeekdays(let days):
         weeklyFreqSelection = .specificWeekdays(days)
         selection = .specificWeekdays(days)
      case let .timesPerWeek(times: n, resetDay: resetDay):
         weeklyFreqSelection = .timesPerWeek(times: n, resetDay: resetDay)
         selection = .timesPerWeek(times: n, resetDay: resetDay)
      }
   }
   
   var body: some View {
//      print("Frequency selection stack body")
//      let _ = Self._printChanges()
      return (
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
                     changeFrequency(to: .timesPerDay(timesPerDay))
                  }
            } onSelection: {
               changeFrequency(to: .timesPerDay(timesPerDay))
            }
            .transition(.move(edge: .leading))
         }
         
         if segmentSelection == .weekly {
            SelectableFrequencyCard(selection: $weeklyFreqSelection, type: .specificWeekdays([.sunday])) {
               EveryWeekOnSpecificWeekDays(selectedWeekdays: $daysPerWeek)
                  .onChange(of: daysPerWeek) { newValue in
                     changeFrequency(to: .specificWeekdays(daysPerWeek))
                  }
            } onSelection: {
               changeFrequency(to: .specificWeekdays(daysPerWeek))
            }
            .transition(.move(edge: .trailing))
            
            SelectableFrequencyCard(selection: $weeklyFreqSelection, type: .timesPerWeek(times: 1, resetDay: .sunday)) {
               XTimesPerWeekBeginningEveryY(timesPerWeek: $timesPerWeek.times, beginningDay: $timesPerWeek.resetDay)
                  .onChange(of: timesPerWeek.times) { newValue in
                     changeFrequency(to: .timesPerWeek(times: timesPerWeek.times, resetDay: timesPerWeek.resetDay))
                  }
                  .onChange(of: timesPerWeek.resetDay) { newValue in
                     changeFrequency(to: .timesPerWeek(times: timesPerWeek.times, resetDay: timesPerWeek.resetDay))
                  }
            } onSelection: {
               changeFrequency(to: .timesPerWeek(times: timesPerWeek.times, resetDay: timesPerWeek.resetDay))
            }
            .transition(.move(edge: .trailing))
         }
         
//         Text("More frequency options coming soon!")
//            .padding(.top, 10)
//            .foregroundColor(.secondaryLabel)
         
         Spacer()
      }
      .onChange(of: segmentSelection) { newValue in
         switch segmentSelection {
         case .daily:
            changeFrequency(to: .timesPerDay(timesPerDay))
         case .weekly:
            if case .specificWeekdays = weeklyFreqSelection {
               changeFrequency(to: .specificWeekdays(daysPerWeek))
            } else if case .timesPerWeek = weeklyFreqSelection {
               changeFrequency(to: .timesPerWeek(times: timesPerWeek.times, resetDay: timesPerWeek.resetDay))
            }
         }
      }
      .animation(.easeInOut(duration: 0.2), value: segmentSelection)
      )
   }
}

struct FrequencySelectionStack_Previewer: View {
   @State private var selection: HabitFrequency = .timesPerDay(1)
   var body: some View {
      VStack {
         Background {
            FrequencySelectionStack(selection: $selection)
         }
      }
   }
}

struct FrequencySelectionStack_Previews: PreviewProvider {
   static var previews: some View {
      FrequencySelectionStack_Previewer()
   }
}
