//
//  ChooseHabitFrequency.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 8/9/22.
//

import SwiftUI
import Introspect

@objc public enum HabitFrequency: Int {
    case daily = 0
    case weekly = 1
//    case monthly = 2
}

enum HabitFrequencyError: Error {
    case zeroFrequency
    case emptyFrequency
}

struct ChooseHabitFrequency: View {
    
    @Environment(\.managedObjectContext) var moc
    
    var habitName: String
    
    @Binding var rootPresenting: Bool
    
    @State private var selectedFrequency: HabitFrequency = .daily
    
    @State private var dailyFrequencyText = "1"
    @State private var timesPerDay: Int = 1
    @State private var timesPerDayZeroError = false
    @State private var timesPerDayEmptyError = false
    
    @State private var daysPerWeek: [Int] = [0]
    
    var body: some View {
        Background {
            VStack {
                HabitCreationHeader(systemImage: "clock.arrow.2.circlepath",
                                    title: "Frequency",
                                    subtitle: "How often do you complete this habit?")
                
                /*
                 Picker(selection: $selectedFrequency, label: Text("Frequency")) {
                 Text("Daily").tag(HabitFrequency.daily)
                 Text("Weekly").tag(HabitFrequency.weekly)
                 //                    Text("Monthly").tag(Frequency.monthly)
                 }
                 .pickerStyle(.segmented)
                 .padding(10)
                 
                 
                 switch selectedFrequency {
                 case .daily:
                 EveryDaily(frequencyText: $dailyFrequencyText)
                 case .weekly:
                 EveryWeekly(selectedWeekdays: $daysPerWeek)
                 //                    WeeklyCards()
                 //                case .monthly:
                 //                    Text("Monthly")
                 }
                 */
                
                EveryDaily(timesPerDay: $timesPerDay)
                
                Spacer()
                
                BottomButton(label: "Finish")
                    .onTapGesture {
                        do {
                            let habit = try Habit(context: moc,
                                                  name: habitName,
                                                  noNameDupe: false,
                                                  timesPerDay: timesPerDay,
                                                  daysPerWeek: daysPerWeek)
                            
                            // Auto trackers
                            let it = ImprovementTracker(context: moc, habit: habit)
                            habit.addToTrackers(it)
                            rootPresenting = false
                        } catch {
                            fatalError("unkown error in choose habit frequency")
                        }
                    }
            }
        }
    }
}

struct HabitFrequency_Previews: PreviewProvider {
    static var previews: some View {
        ChooseHabitFrequency(habitName: "Horseback Riding", rootPresenting: .constant(false))
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
