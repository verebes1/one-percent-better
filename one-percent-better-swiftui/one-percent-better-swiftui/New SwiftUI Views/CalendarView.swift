//
//  CalendarView.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 4/27/22.
//

import SwiftUI

struct CalendarView: View {
    
    @EnvironmentObject var habit: Habit
    
    /// Object used to calculate an array of days for each month
    var calendarCalculator = CalendarCalculator()
    
    var body: some View {
        
        let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 7)
        
        let smwttfs = ["S", "M", "T", "W", "T", "F", "S"]
    
        VStack {
            HStack(spacing: 0) {
                Text("December 2022")
                    .font(.system(size: 19))
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("23 of 30 days")
                    .font(.system(size: 15))
                    .foregroundColor(Color(hue: 1.0, saturation: 0.009, brightness: 0.239))
                    
                
                RingView(percent: 0.5,
                         size: 20)
                    .frame(width: 30, height: 30)
            }
            .padding(.horizontal, 15)
                
            LazyVGrid(columns: columns) {
                ForEach(0..<7) { i in
                    Text(smwttfs[i])
                        .fontWeight(.regular)
                        .foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.393))
                        
                }
            }
            
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(calendarCalculator.days, id: \.date) { day in
                    CalendarDayView(day: day,
                                    width: 23,
                                    height: 23)
                    .padding(.vertical, 2)
                }
            }
        }
    }
}


struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        let context = CoreDataManager.previews.persistentContainer.viewContext
        let habit = PreviewData.calendarViewData()
        
        Background {
            CardView {
                CalendarView()
                    .environmentObject(habit)
                    .environment(\.managedObjectContext, context)
            }
        }
    }
}


struct CalendarDayView: View {
    
    @EnvironmentObject var habit: Habit
    
    let day: Day
    
    var width: CGFloat? = nil
    var height: CGFloat? = nil
    
    var body: some View {
        VStack (spacing: 0) {
            
            Text(day.dayNumber)
                .font(.system(size: 14))
                .foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.104))
            
            if Calendar.current.isDateInToday(day.date) {
                if habit.wasCompleted(on: day.date) {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.green)
                        .frame(width: width, height: height)
                } else {
                    Circle()
                        .stroke(.gray, style: .init(lineWidth: 1))
                        .frame(width: width, height: height)
                }
            } else {
                if habit.wasCompleted(on: day.date) {
                    Circle()
                        .foregroundColor(.green.opacity(day.isWithinDisplayedMonth ? 1 : 0.2))
                        .frame(width: width, height: height)
                } else {
                    Circle()
                        .foregroundColor(Color.calendarGray.opacity(day.isWithinDisplayedMonth ? 1 : 0.2))
                        .frame(width: width, height: height)
                    
                    
                }
            }
        }
        
    }
}

struct CalendarDayView_Previews: PreviewProvider {
    static var previews: some View {
        let habit = PreviewData.calendarViewData()
        
        let day0 = Day(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, isWithinDisplayedMonth: false)
        let day1 = Day(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, isWithinDisplayedMonth: true)
        let day2 = Day(date: Date(), isWithinDisplayedMonth: true)
        
        HStack {
            CalendarDayView(day: day0, width: 30, height: 30)
                .environmentObject(habit)
            
            CalendarDayView(day: day1, width: 30, height: 30)
                .environmentObject(habit)
            
            CalendarDayView(day: day2, width: 30, height: 30)
            .environmentObject(habit)
        }
    }
}
