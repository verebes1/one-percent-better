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
      h?.markCompleted(on: Calendar.current.date(byAdding: .day, value: -100, to: Date())!)
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
