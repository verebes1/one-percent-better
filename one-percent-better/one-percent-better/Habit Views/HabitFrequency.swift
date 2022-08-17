//
//  HabitFrequency.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 8/9/22.
//

import SwiftUI

fileprivate enum Frequency: String {
    case daily = "Daily"
    case weekly = "Weekly"
//    case monthly = "Monthly"
    
    var everyText: String {
        switch self {
        case .daily:
            return "day(s)"
        case .weekly:
            return "week(s)"
//        case .monthly:
//            return "month(s)"
        }
    }
}

struct HabitFrequency: View {
    
    @State private var showFrequencyMenu = false
    
    @State private var selectedFrequency: Frequency = .daily
    
    var body: some View {
        Background {
            VStack {
                HabitCreationHeader(systemImage: "clock.arrow.2.circlepath",
                                    title: "Frequency",
                subtitle: "How often do you want to complete this habit?")
                
                
                HStack {
                    Text("Frequency:")
                    
                    ZStack {
                        
                        Text(selectedFrequency.rawValue)
                        
                        Menu("             ") {
                            Button("Daily") {
                                selectedFrequency = .daily
                            }
                            Button("Weekly") {
                                selectedFrequency = .weekly
                            }
//                            Button("Montly") {
//                                selectedFrequency = .monthly
//                            }
                        }
                        .foregroundColor(.blue)
                        .padding(10)
                        .background(.cyan.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                }
                
                
                switch selectedFrequency {
                case .daily:
                    EveryDaily()
                case .weekly:
                    WeeklyCards()
//                case .monthly:
//                    Text("Monthly")
                }
                
                
                Spacer()
                
            }
        }
    }
}

struct HabitFrequency_Previews: PreviewProvider {
    static var previews: some View {
        HabitFrequency()
    }
}

struct EveryDaily: View {
    
    @State private var frequencyText = "1"
    
    var body: some View {
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
    }
}

struct WeeklyCards: View {
    
    @State private var selectedCard: Int = 0
    
    @State private var specificDaysSelected = true
    
    var body: some View {
        VStack {
            SelectableCard(selection: $specificDaysSelected) {
                EveryWeekly()
            }
            
            
            CardView {
                Text("Every 1 week(s) at anytime during that period")
            }
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
                Text("Every")
                ZStack {
                    RoundedRectangle(cornerRadius: 7)
                        .foregroundColor(.systemGray5)
                    
                    TextField("", text: $frequencyText)
                        .multilineTextAlignment(.center)
                }
                .frame(width: 35, height: 25)
                Text("week(s) on:")
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
