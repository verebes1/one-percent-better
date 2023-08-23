//
//  SelectedDayView.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 8/22/23.
//

import SwiftUI

struct SelectedDayView: View {
    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var vm: HeaderWeekViewModel
    @EnvironmentObject var hsvm: HeaderSelectionViewModel
    
    var index: Int
    var color: Color = .systemTeal
    
    func isIndexSameAsToday(_ index: Int) -> Bool {
        let dayIsSelectedWeekday = vm.thisWeekDayOffset(Date()) == index
        let weekIsSelectedWeek = hsvm.selectedWeek == (vm.numWeeksSinceEarliest - 1)
        return dayIsSelectedWeekday && weekIsSelectedWeek
    }
    
    func weekdayLabelColor(isSelected: Bool) -> Color {
        if isSelected {
            if isIndexSameAsToday(index) {
                return scheme == .light ? .white : .black
            } else {
                return .white
            }
        } else {
            return (isIndexSameAsToday(index) ? color : .secondary)
        }
    }
    
    let smwttfs = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        ZStack {
            let circleSize: CGFloat = 19
            let isSelected = index == vm.thisWeekDayOffset(hsvm.selectedDay)
            if isSelected {
                Circle()
                    .foregroundColor(isIndexSameAsToday(index) ? color : .systemGray2)
                    .frame(width: circleSize, height: circleSize)
            }
            Text(smwttfs[index])
                .font(.system(size: 12))
                .fontWeight(isIndexSameAsToday(index) && !isSelected ? .medium : .regular)
                .foregroundColor(weekdayLabelColor(isSelected: isSelected))
                .frame(maxWidth: .infinity)
        }
        .padding(.bottom, 3)
        .contentShape(Rectangle())
        .onTapGesture {
            let dayOffset = vm.dayOffset(week: hsvm.selectedWeek, day: index)
            if dayOffset <= 0 {
                hsvm.selectedWeekDay = index
                hsvm.selectedDay = Cal.date(byAdding: .day, value: dayOffset, to: Date())!
            }
        }
    }
}


struct SelectedDayView_Previews: PreviewProvider {
    static var previews: some View {
        SelectedDayView(index: 0)
    }
}
