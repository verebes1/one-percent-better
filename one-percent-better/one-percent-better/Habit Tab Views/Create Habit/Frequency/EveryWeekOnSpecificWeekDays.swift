//
//  EveryWeekOnSpecificWeekDays.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 9/27/22.
//

import SwiftUI


struct EveryWeekOnSpecificWeekDays: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var sowm: StartOfWeekModel
    @Binding var selectedWeekdays: Set<Weekday>
    
    
    var body: some View {
        VStack {
            Text("Every week on")
            HStack(spacing: 3) {
                ForEach(Weekday.orderedCases) { weekday in
                    WeekDayButton(weekday: weekday, selectedWeekdays: $selectedWeekdays)
                }
            }
            .padding(.horizontal, 25)
        }
        .padding(.vertical, 10)
    }
}

struct WeekDayButton: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let weekday: Weekday
    @Binding var selectedWeekdays: Set<Weekday>
    
    func updateSelection() {
        if selectedWeekdays.count == 1 && selectedWeekdays.contains(weekday) {
            return
        } else if let index = selectedWeekdays.firstIndex(of: weekday) {
            selectedWeekdays.remove(at: index)
        } else {
            selectedWeekdays.insert(weekday)
        }
    }
    
    private var textColor: Color {
        colorScheme == .light ? .black : .white
    }
    
    private var selectedTextColor: Color {
        colorScheme == .light ? .white : .black
    }
    
    private var buttonGray: Color {
        colorScheme == .light ? .systemGray5 : .systemGray3
    }
    
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                updateSelection()
            }
        } label : {
            let isSelected = selectedWeekdays.contains(weekday)
            Text(weekday.letter)
                .font(.system(size: 15))
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.vertical, 5)
                .frame(width: 40)
                .foregroundColor(isSelected ? selectedTextColor : textColor)
                .background(isSelected ? Style.accentColor : buttonGray)
                .clipShape(Capsule())
        }
    }
}

struct EveryWeekOnSpecificWeekDaysPreviews: View {
    @State var selectedWeekdays: Set<Weekday> = [.monday, .tuesday]
    
    var body: some View {
        Background {
            CardView {
                EveryWeekOnSpecificWeekDays(selectedWeekdays: $selectedWeekdays)
            }
        }
    }
}

struct EveryWeekOnSpecificWeekDays_Previews: PreviewProvider {
    static var previews: some View {
        EveryWeekOnSpecificWeekDaysPreviews()
    }
}


