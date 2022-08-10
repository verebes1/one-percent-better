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
    case monthly = "Monthly"
    
    var everyText: String {
        switch self {
        case .daily:
            return "day(s)"
        case .weekly:
            return "week(s)"
        case .monthly:
            return "month(s)"
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
                        
                        Menu("               ") {
                            Button("Daily") {
                                selectedFrequency = .daily
                            }
                            Button("Weekly") {
                                selectedFrequency = .weekly
                            }
                            Button("Montly") {
                                selectedFrequency = .monthly
                            }
                        }
                        .foregroundColor(.blue)
                        .padding(10)
                        .background(.cyan.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                }
                
                
                
                EveryWeekly(selectedFrequency: selectedFrequency)
                
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

struct EveryWeekly: View {
    
    fileprivate var selectedFrequency: Frequency
    
    @State private var frequencyText = "1"
    
    let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
    
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
                Text("\(selectedFrequency.everyText) on:")
            }
            
            
            HStack(spacing: 1) {
                ForEach(0 ..< 7) { i in
                    ZStack {
                        Rectangle()
                            .foregroundColor(.systemGray3)
                        
                        Text(weekdays[i])
                    }
                    .frame(height: 30)
                }
            }
            .padding(.horizontal, 15)
        }
    }
}
