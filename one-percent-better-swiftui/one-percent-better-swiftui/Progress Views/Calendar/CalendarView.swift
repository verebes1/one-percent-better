//
//  CalendarView.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 4/27/22.
//

import SwiftUI

struct CalendarView: View {
    
    @EnvironmentObject var habit: Habit
    
    @State var currentPage: Int = 0

    var body: some View {
        
        /// Object used to calculate an array of days for each month
        let calendarModel = CalendarModel(habit: habit)
        
        let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 7)
        let smwttfs = ["S", "M", "T", "W", "T", "F", "S"]
    
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                
                Text(calendarModel.headerMonth(page: currentPage))
                    .font(.system(size: 19))
                    .fontWeight(.medium)
                
                Spacer()
                
                let (completed, total) = calendarModel.numCompleted(page: currentPage)
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
                TabView(selection: $currentPage) {
                    let numMonths = calendarModel.numMonthsSinceStart
                    ForEach(0 ..< numMonths, id: \.self) { i in
                        
                        let spacing = CGFloat(calendarModel.numWeeksInMonth(page: currentPage))
                        LazyVGrid(columns: columns, spacing: spacing) {
                            let offset = numMonths - 1 - i
                            ForEach(calendarModel.backXMonths(x: offset), id: \.date) { day in
                                CalendarDayView(day: day,
                                                fontSize: 13,
                                                circleSize: 22)
                            }
                        }
                        .animation(.easeInOut, value: spacing)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(width: UIScreen.main.bounds.width - 20, height: 240)
                .onAppear {
                    currentPage = calendarModel.numMonthsSinceStart - 1
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
        .preferredColorScheme(.dark)
        
    }
}


struct CalendarDayView: View {
    
    @EnvironmentObject var habit: Habit
    
    let day: Day
    
    let fontSize: CGFloat
    var circleSize: CGFloat
    
    var body: some View {
        VStack (spacing: 0) {
            
            Text(day.dayNumber)
                .font(.system(size: fontSize))
                .foregroundColor(.calendarNumberColor)
            
            if Calendar.current.isDateInToday(day.date) {
                if habit.wasCompleted(on: day.date) {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.green)
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
                CalendarDayView(day: day0, fontSize: fontSize, circleSize: circleSize)
                    .environmentObject(habit1)
                
                CalendarDayView(day: day1, fontSize: fontSize, circleSize: circleSize)
                    .environmentObject(habit1)
                
                CalendarDayView(day: day2, fontSize: fontSize, circleSize: circleSize)
                .environmentObject(habit1)
                
                CalendarDayView(day: today, fontSize: fontSize, circleSize: circleSize)
                .environmentObject(habit2)
                
            }
                .preferredColorScheme(.dark)
        )
    }
}
