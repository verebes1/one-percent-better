//
//  ChooseHabitFrequency.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 8/9/22.
//

import SwiftUI

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
            Spacer()
               .frame(height: 20)
            HabitCreationHeader(systemImage: "clock.arrow.2.circlepath",
                                title: "Frequency",
                                subtitle: "How often do you want to complete this habit?")
            
//            Spacer().frame(height: 20)
            
            FrequencySelectionStack(vm: vm)
               .environmentObject(vm)
            
            Spacer()
            
            BottomButton(label: "Finish")
               .onTapGesture {
                  let _ = try? Habit(context: moc,
                                     name: habitName,
                                     // TODO: 1.0.8 RESET THIS WHEN FINISHED WORKING ON NEW FREQUENCIES
//                                     frequency: vm.selection)
                                     frequency: .timesPerDay(1))
                  nav.path.removeLast(2)
               }
         }
         .toolbar(.hidden, for: .tabBar)
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
         //                EveryWeekOnSpecificWeekDays()
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

