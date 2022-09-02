//
//  CalendarView.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 4/27/22.
//

import SwiftUI

struct CalendarView: View {
    
    let habit: Habit
    
    /// Object used to calculate an array of days for each month
    @ObservedObject var calendarModel: CalendarModel
    
    init(habit: Habit) {
        self.habit = habit
        self.calendarModel = CalendarModel(habit: habit)
    }

    var body: some View {
        
        let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 7)
        let smwttfs = ["S", "M", "T", "W", "T", "F", "S"]
    
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                
                Text(calendarModel.headerMonth)
                    .font(.system(size: 19))
                    .fontWeight(.medium)
                
                Spacer()
                
                let (completed, total) = calendarModel.numCompleted
                Text("\(completed) of \(total) days")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    
                let percent: Double = Double(completed) / Double(total)
                RingView(percent: percent,
                         size: 20)
                    .frame(width: 30, height: 30)
            }
            .padding(.leading, 15)
            .padding(.trailing, 10)
            .padding(.bottom, 5)
                
            LazyVGrid(columns: columns) {
                ForEach(0..<7) { i in
                    Text(smwttfs[i])
                        .fontWeight(.regular)
                        .foregroundColor(.secondary)
                        
                }
            }
            
            VStack {
                TabView(selection: $calendarModel.currentPage) {
                    let numMonths = calendarModel.numMonthsSinceStart
                    ForEach(0 ..< numMonths, id: \.self) { i in
                        
                        LazyVGrid(columns: columns, spacing: calendarModel.rowSpacing) {
                            let offset = numMonths - 1 - i
                            ForEach(calendarModel.backXMonths(x: offset), id: \.date) { day in
                                CalendarDayView(habit: habit,
                                                day: day,
                                                fontSize: 13,
                                                circleSize: 22)
                            }
                        }
                        .animation(.easeInOut, value: calendarModel.rowSpacing)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(width: UIScreen.main.bounds.width - 20, height: 240)
                .onAppear {
                    
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
                CalendarView(habit: habit)
                    .environment(\.managedObjectContext, context)
            }
        }
        
        
    }
}


struct CalendarDayView: View {
    
    let habit: Habit
    let day: Day
    let fontSize: CGFloat
    var circleSize: CGFloat
    
    var body: some View {
        VStack (spacing: 0) {
            if day.isWithinDisplayedMonth {
                Text(day.dayNumber)
                    .font(.system(size: fontSize))
                    .foregroundColor(.calendarNumberColor)
                
                if Calendar.current.isDateInToday(day.date) {
                    if habit.wasCompleted(on: day.date) {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.green.opacity(day.isWithinDisplayedMonth ? 1 : 0.2))
                            .frame(width: circleSize, height: circleSize)
                    } else {
                        Circle()
                            .stroke(.gray, style: .init(lineWidth: 1))
                            .frame(width: circleSize, height: circleSize)
                    }
                } else {
                    if habit.wasCompleted(on: day.date) {
                        Circle()
                            .foregroundColor(.green.opacity(day.isWithinDisplayedMonth ? 1 : 0.2))
                            .frame(width: circleSize, height: circleSize)
                    } else {
                        Circle()
                            .foregroundColor(.systemGray3.opacity(day.isWithinDisplayedMonth ? 1 : 0.2))
                            .frame(width: circleSize, height: circleSize)
                    }
                }
            }
        }
        
    }
}

struct CalendarDayView_Previews: PreviewProvider {
    static var previews: some View {
        
        let context = CoreDataManager.previews.persistentContainer.viewContext
        
        let h1 = try? Habit(context: context, name: "A")
        h1?.markCompleted(on: Date())
        let _ = try? Habit(context: context, name: "B")
        
        let habits = Habit.habitList(from: context)
        
        let habit1 = habits.first!
        let habit2 = habits.last!
        
        let day0 = Day(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, isWithinDisplayedMonth: false)
        let day1 = Day(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, isWithinDisplayedMonth: true)
        let day2 = Day(date: Date(), isWithinDisplayedMonth: true)
        
        let today = Day(date: Date(), isWithinDisplayedMonth: true)
        
        let fontSize: CGFloat = 19
        let circleSize: CGFloat = 30
        
        return (
            HStack {
                CalendarDayView(habit: habit1,
                                day: day0,
                                fontSize: fontSize,
                                circleSize: circleSize)
                
                CalendarDayView(habit: habit1,
                                day: day1,
                                fontSize: fontSize,
                                circleSize: circleSize)
                
                CalendarDayView(habit: habit1,
                                day: day2,
                                fontSize: fontSize,
                                circleSize: circleSize)
                
                CalendarDayView(habit: habit2,
                                day: today,
                                fontSize: fontSize,
                                circleSize: circleSize)
                
            }
                
        )
    }
}
