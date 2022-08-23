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
    
    @Binding var rootPresenting: Bool
    
    @State private var showFrequencyMenu = false
    
    @State private var selectedFrequency: HabitFrequency = .daily
    
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
                    EveryDaily()
                case .weekly:
                    WeeklyCards()
//                case .monthly:
//                    Text("Monthly")
                }
                
                
                Spacer()
                
                BottomButton(label: "Finish")
                    .onTapGesture {
                        print("test")
                    }
            }
        }
    }
}

struct HabitFrequency_Previews: PreviewProvider {
    static var previews: some View {
        ChooseHabitFrequency(rootPresenting: .constant(false))
    }
}

struct EveryDaily: View {
    
    @State private var frequencyText = "1"
    
    var body: some View {
        CardView {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 7)
                        .foregroundColor(.systemGray5)
                    
                    TextField("", text: $frequencyText)
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
            
            CardView {
                EveryWeekly()
                    .padding()
            }
            
            
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
    
    @State private var selectedWeekdays: [Int] = [0]
    
    func updateSelection(_ i: Int) {
        if selectedWeekdays.count == 1 && i == selectedWeekdays.first! {
            return
        }
        if let index = selectedWeekdays.firstIndex(of: i) {
            selectedWeekdays.remove(at: index)
        } else {
            selectedWeekdays.append(i)
        }
    }
    
    var body: some View {
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
