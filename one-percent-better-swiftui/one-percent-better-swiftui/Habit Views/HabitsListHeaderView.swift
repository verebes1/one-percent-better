//
//  HabitsListHeaderView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/3/22.
//

import SwiftUI

struct HabitsListHeaderView: View {
    
    @Binding var currentDay: Date
    
    @State var selectedWeekDay: Int = 0
    @State var selectedWeek: Int = 0
    
    var body: some View {
        VStack {
//            Text("selectedWeekDay: \(selectedWeekDay)")
//            Spacer()
//                .frame(height: 50)
            
            VStack(spacing: 0) {
                
                HStack {
                    ForEach(0 ..< 7) { i in
                        SelectedDayView(index: i,
                                        selectedWeekDay: $selectedWeekDay,
                                        currentDay: $currentDay)
                    }
                }
                .padding(.horizontal, 20)
                
                let ringSize: CGFloat = 27
                let numWeeks: Int = 5
                TabView {
                    ForEach(0 ..< numWeeks, id: \.self) { i in
                        HStack {
                            ForEach(0 ..< 7) { j in
                                RingView(percent: 0.3,
                                         size: ringSize)
                                .frame(maxWidth: .infinity)
                                .onTapGesture {
                                    selectedWeekDay = j
                                }
                                .contentShape(Rectangle())
//                                .border(.black.opacity(0.2))
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .frame(height: ringSize + 9)
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .onAppear {
                if !Calendar.current.isDate(currentDay, inSameDayAs: Date()) {
                    currentDay = Date()
                }
                selectedWeekDay = Calendar.current.component(.weekday, from: currentDay) - 1
            }
        }
        
    }
    
}

struct HabitsListHeaderView_Previews: PreviewProvider {
    
    @State static var currentDay = Date()
    
    static var previews: some View {
        HabitsListHeaderView(currentDay: $currentDay)
    }
}

struct SelectedDayView: View {
    
    var index: Int
    @Binding var selectedWeekDay: Int
    @Binding var currentDay: Date
    
    func selectedIsToday(_ index: Int) -> Bool {
        let currentDayIsToday = Calendar.current.isDateInToday(currentDay)
        let selectedDayIsToday = (Calendar.current.component(.weekday, from: currentDay) - 1) == index
        return currentDayIsToday && selectedDayIsToday
    }
    
    let smwttfs = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        ZStack {
            let circleSize: CGFloat = 19
            let isSelected = index == selectedWeekDay
            if isSelected {
                Circle()
                    .foregroundColor(selectedIsToday(index) ? .systemRed : .systemGray3)
                    .frame(width: circleSize, height: circleSize)
            }
            Text(smwttfs[index])
                .font(.system(size: 12))
                .fontWeight(.regular)
                .foregroundColor(isSelected ? .white : (selectedIsToday(index) ? .systemRed : .secondary))
                .frame(maxWidth: .infinity)
        }
        .padding(.bottom, 3)
        .contentShape(Rectangle())
//        .border(.black.opacity(0.2))
        .onTapGesture {
            selectedWeekDay = index
        }
    }
}
