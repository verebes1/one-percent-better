//
//  SelectedDayView.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 8/22/23.
//

import SwiftUI

struct SelectedDayView: View {
    @Environment(\.colorScheme) var scheme
    
    var weekday: Weekday
    var selectedWeekday: Weekday
    var isToday: Bool
    
    var isSelected: Bool {
        weekday == selectedWeekday
    }
    
    var weekdayLabelColor: Color {
        if isSelected {
            if isToday {
                return scheme == .light ? .white : .black
            } else {
                return .white
            }
        } else {
            return (isToday ? Style.accentColor : .secondary)
        }
    }
    
    var body: some View {
        ZStack {
            let circleSize: CGFloat = 19
            if isSelected {
                Circle()
                    .foregroundColor(isToday ? Style.accentColor : .systemGray2)
                    .frame(width: circleSize, height: circleSize)
            }
            Text(weekday.letter)
                .font(.system(size: 12))
                .fontWeight(.medium)
                .foregroundColor(weekdayLabelColor)
                .frame(maxWidth: .infinity)
        }
        .padding(.bottom, 3)
        .contentShape(Rectangle())
    }
}


struct SelectedDayView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SelectedDayView(weekday: .monday, selectedWeekday: .monday, isToday: true)
        }
    }
}
