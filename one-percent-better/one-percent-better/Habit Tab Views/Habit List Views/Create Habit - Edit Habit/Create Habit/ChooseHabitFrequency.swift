//
//  ChooseHabitFrequency.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 8/9/22.
//

import SwiftUI
import Introspect

enum HabitFrequencyError: Error {
  case zeroFrequency
  case emptyFrequency
}

struct ChooseHabitFrequency: View {
  
  @Environment(\.managedObjectContext) var moc
  
  @EnvironmentObject var nav: HabitTabNavPath
  
  @EnvironmentObject var hlvm: HabitListViewModel
  
  var habitName: String
  
  @ObservedObject var vm = FrequencySelectionModel(selection: .timesPerDay(1))
  
  var body: some View {
    Background {
      VStack {
        HabitCreationHeader(systemImage: "clock.arrow.2.circlepath",
                            title: "Frequency",
                            subtitle: "How often do you complete this habit?")
        
         FrequencySelectionStack(vm: vm)
          .environmentObject(vm)
        
        Spacer()
        
        BottomButton(label: "Finish")
          .onTapGesture {
            do {
              let habit = try Habit(context: moc,
                                    name: habitName,
                                    noNameDupe: false,
                                    frequency: vm.selection)
              
              // Auto trackers
              let it = ImprovementTracker(context: moc, habit: habit)
              habit.addToTrackers(it)
            } catch {
              fatalError("unkown error in choose habit frequency")
            }
            
            nav.path.removeLast(2)
          }
      }
    }
  }
}

struct HabitFrequency_Previews: PreviewProvider {
  static var previews: some View {
    ChooseHabitFrequency(habitName: "Horseback Riding")
  }
}

struct WeeklyCards: View {
  
  @State private var selectedCard: Int = 0
  
  @State private var specificDaysSelected = true
  
  var body: some View {
    VStack {
      //            SelectableCard(selection: $specificDaysSelected) {
      //                EveryWeekly()
      //            }
      //            .frame(height: 90)
      
      //            CardView {
      //                EveryWeekly()
      //                    .padding()
      //            }
      
      
      //            CardView {
      //                Text("Every 1 week(s) at anytime during that period")
      //            }
      //            .border(selectedCard == 1 ? .blue : .clear)
      //            .onTapGesture {
      //                selectedCard = 1
      //            }
    }
  }
}

