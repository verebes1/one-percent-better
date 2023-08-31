//
//  FrequencySelectionStack.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 12/30/22.
//

import SwiftUI
import Combine

class FrequencySelectionStackModel: ObservableObject {
   /// The selected frequency
   @Published var selection: HabitFrequency
   
   /// Times per day selection
   @Published var timesPerDay = 1
   
   /// Specific weekdays selection
   @Published var weekdays: Set<Weekday> = [.monday, .wednesday]
   
   /// Times per week selections
   @Published var timesPerWeek = 1
   @Published var resetDay: Weekday = .sunday
   
   private var cancelBag: Set<AnyCancellable> = []
   
   init(selection: HabitFrequency) {
      self.selection = selection
      
      // Update selected card to initial value
      switch selection {
      case .timesPerDay(let times):
         self.timesPerDay = times
      case .specificWeekdays(let weekdays):
         self.weekdays = Set(weekdays)
      case .timesPerWeek(let times, let resetDay):
         self.timesPerWeek = times
         self.resetDay = resetDay
      }
      
      setupObservables()
   }
   
   /// Observe changes to the card models and update the selection accordingly
   func setupObservables() {
      // Times per day
      $timesPerDay
         .dropFirst()
         .sink { times in
            self.selection = .timesPerDay(times)
         }
         .store(in: &cancelBag)
      
      // Specific weekdays
      $weekdays
         .dropFirst()
         .sink { weekdays in
            self.selection = .specificWeekdays(weekdays)
         }
         .store(in: &cancelBag)
      
      // Times per week
      $timesPerWeek
         .dropFirst()
         .sink { times in
            self.selection = .timesPerWeek(times: times, resetDay: self.resetDay)
         }
         .store(in: &cancelBag)
      
      $resetDay
         .dropFirst()
         .sink { resetDay in
            self.selection = .timesPerWeek(times: self.timesPerWeek, resetDay: resetDay)
         }
         .store(in: &cancelBag)
   }
   
   /// Update the selection to match this "card" type
   /// - Parameter type: The type to match to, but using the details in this model
   func updateSelection(to type: HabitFrequency) {
      switch type {
      case .timesPerDay:
         selection = .timesPerDay(timesPerDay)
      case .specificWeekdays:
         selection = .specificWeekdays(weekdays)
      case .timesPerWeek:
         selection = .timesPerWeek(times: timesPerWeek, resetDay: resetDay)
      }
   }
}

struct FrequencySelectionStack: View {
   
   @Environment(\.colorScheme) var scheme
   
   /// Model for the frequency selection
   @EnvironmentObject var fssm: FrequencySelectionStackModel
   
   var body: some View {
      VStack(spacing: 20) {
         SelectableFrequencyCard(type: .timesPerDay(1)) {
            EveryDayXTimesPerDay(timesPerDay: $fssm.timesPerDay)
         }
         
         SelectableFrequencyCard(type: .specificWeekdays([])) {
            EveryWeekOnSpecificWeekDays(selectedWeekdays: $fssm.weekdays)
         }
         
         SelectableFrequencyCard(type: .timesPerWeek(times: 1,
                                                     resetDay: .sunday)) {
            XTimesPerWeekBeginningEveryY(timesPerWeek: $fssm.timesPerWeek,
                                         beginningDay: $fssm.resetDay)
         }
      }
   }
}

struct SelectableFrequencyCard<Content>: View where Content: View {
   /// Model for the frequency selection
   @EnvironmentObject var fssm: FrequencySelectionStackModel
   
   /// The type for this card
   let type: HabitFrequency
   
   /// The content of the card
   let content: () -> Content
   
   var body: some View {
      SelectableCard(isSelected: type.equalType(to: fssm.selection)) {
         content()
      } onSelection: {
         fssm.updateSelection(to: type)
      }
   }
}

struct FrequencySelectionStack_Previewer: View {
   @StateObject private var fssm = FrequencySelectionStackModel(selection: .timesPerDay(1))
   var body: some View {
      VStack {
         Background {
            FrequencySelectionStack()
               .environmentObject(fssm)
         }
      }
   }
}

struct FrequencySelectionStack_Previews: PreviewProvider {
   static var previews: some View {
      FrequencySelectionStack_Previewer()
   }
}
