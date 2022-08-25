//
//  ChooseHabitFrequency.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 8/9/22.
//

import SwiftUI
import Introspect

@objc public enum HabitFrequency: Int16 {
    case daily = 0
    case weekly = 1
//    case monthly = 2
}

struct ChooseHabitFrequency: View {
    
    @Environment(\.managedObjectContext) var moc
    
    var habitName: String
    
    @Binding var rootPresenting: Bool
    
    @State private var selectedFrequency: HabitFrequency = .daily
    
    @State private var dailyFrequencyText = "1"
    @State private var timesPerDay: Int = 1
    
    @State private var daysPerWeek: [Int] = [0]
    
    func isValid() -> Bool {
        switch selectedFrequency {
        case .daily:
            if let timesPerDay = Int(dailyFrequencyText) {
                self.timesPerDay = timesPerDay
                return true
            }
        case .weekly:
            return true
        }
        return false
    }
    
    var body: some View {
        Background {
            VStack {
                HabitCreationHeader(systemImage: "clock.arrow.2.circlepath",
                                    title: "Frequency",
                subtitle: "How often do you want to complete this habit?")
                
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
                
                
                Spacer()
                
                BottomButton(label: "Finish")
                    .onTapGesture {
                        if isValid() {
                            do {
                                let habit = try Habit(context: moc,
                                                   name: habitName,
                                                   noNameDupe: false,
                                                   timesPerDay: timesPerDay,
                                                   daysPerWeek: daysPerWeek)
                                
                                // Auto trackers
                                let it = ImprovementTracker(context: moc, habit: habit)
                                habit.addToTrackers(it)
                            } catch {
                                fatalError("Unable to create habit")
                            }
                            
                            rootPresenting = false
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

struct EveryDaily: View {
    
    @Binding var frequencyText: String
    
    var body: some View {
        CardView {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 7)
                        .foregroundColor(.systemGray5)
                    
                    TextField("", text: $frequencyText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                }
                .frame(width: 35, height: 25)
                Text("time(s) per day")
            }
            .padding()
        }
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

struct EveryWeekly: View {
    
    @State private var frequencyText = "1"
    
    let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
    
    @Binding var selectedWeekdays: [Int]
    
    func updateSelection(_ i: Int) {
        if selectedWeekdays.count == 1 && i == selectedWeekdays[0] {
            return
        }
        if let index = selectedWeekdays.firstIndex(of: i) {
            selectedWeekdays.remove(at: index)
        } else {
            selectedWeekdays.append(i)
        }
    }
    
    var body: some View {
        CardView {
            VStack {
                HStack {
                    Text("Every week on")
                    //                ZStack {
                    //                    RoundedRectangle(cornerRadius: 7)
                    //                        .foregroundColor(.systemGray5)
                    //
                    //                    TextField("", text: $frequencyText)
                    //                        .multilineTextAlignment(.center)
                    //                }
                    //                .frame(width: 35, height: 25)
                    //                Text("week(s) on:")
                }
                
                
                HStack(spacing: 3) {
                    ForEach(0 ..< 7) { i in
                        ZStack {
                            let isSelected = selectedWeekdays.contains(i)
                            RoundedRectangle(cornerRadius: 3)
                                .foregroundColor(isSelected ? .systemGray : .systemGray3)
                            
                            Text(weekdays[i])
                        }
                        .frame(height: 30)
                        .onTapGesture {
                            updateSelection(i)
                        }
                    }
                }
                .padding(.horizontal, 25)
            }
        }
    }
}
