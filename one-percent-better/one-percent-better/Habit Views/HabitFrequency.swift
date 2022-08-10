//
//  HabitFrequency.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 8/9/22.
//

import SwiftUI

struct HabitFrequency: View {
    
    @State private var showFrequencyMenu = false
    
    enum Frequency: String {
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
    
    @State private var selectedFrequency: Frequency = .daily
    
    @State private var frequencyText = "1"
    
    var body: some View {
        
        VStack {
            HabitCreationHeader(systemImage: "clock.arrow.2.circlepath",
                                title: "Frequency",
            subtitle: "How often do you want to complete this habit?")
            
            
            HStack {
                Text("Frequency")
                Menu(selectedFrequency.rawValue) {
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
                .padding()
            }
            
            HStack {
                Text("Every")
                TextField("", text: $frequencyText)
                    .frame(width: 30)
                    .background(.gray)
                Text("\(selectedFrequency.rawValue) on:")
            }
            
            
            
            Spacer()
            
        }
    }
}

struct HabitFrequency_Previews: PreviewProvider {
    static var previews: some View {
        HabitFrequency()
    }
}
