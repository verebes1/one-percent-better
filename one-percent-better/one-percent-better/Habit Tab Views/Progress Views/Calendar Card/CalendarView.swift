//
//  CalendarView.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 4/27/22.
//

import SwiftUI

struct CalendarView: View {
    
    
    /// Object used to calculate an array of days for each month
    @StateObject var calendarModel: CalendarModel
    
    @StateObject var sowm: StartOfWeekModel
    
    let habit: Habit
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 7)
    
    init(habit: Habit) {
        self.habit = habit
        let sowm = StartOfWeekModel()
        self._sowm = StateObject(wrappedValue: sowm)
        self._calendarModel = StateObject(wrappedValue: CalendarModel(habit: habit, sowm: sowm))
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            CardTitleWithRightDetail(calendarModel.headerMonth) {
                let (completed, total) = calendarModel.numCompleted
                Text("\(completed) of \(total) days")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                
                let percent: Double = Double(completed) / Double(total)
                RingView(percent: percent,
                         size: 20)
                .frame(width: 30, height: 30)
            }
            .padding(.trailing, -10)
            .padding(.bottom, 5)
            
            LazyVGrid(columns: columns) {
                ForEach(Weekday.orderedCases(sowm.startOfWeek)) { weekday in
                    Text(weekday.letter)
                        .fontWeight(.regular)
                        .foregroundColor(.secondary)
                    
                }
            }
            
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
                    .frame(maxHeight: 240)
                    .animation(.easeInOut, value: calendarModel.rowSpacing)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(width: UIScreen.main.bounds.width - 20, height: 240)
            
        }
    }
}


struct CalendarView_Previews: PreviewProvider {
    
    
    static func habit() -> Habit {
        let h = try? Habit(context: CoreDataManager.previews.mainContext, name: "Jumping Jacks")
        let _ = h?.markCompleted(on: Date())
        h?.markCompleted(on: Cal.date(byAdding: .day, value: -100, to: Date())!)
        return Habit.habits(from: CoreDataManager.previews.mainContext).first!
    }
    
    static var previews: some View {
        let habit = habit()
        Background {
            CardView {
                CalendarView(habit: habit)
                    .environment(\.managedObjectContext, CoreDataManager.previews.mainContext)
            }
        }
    }
}
