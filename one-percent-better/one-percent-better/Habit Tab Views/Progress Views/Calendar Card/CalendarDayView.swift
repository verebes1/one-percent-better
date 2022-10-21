//
//  CalendarDayView.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/21/22.
//

import SwiftUI

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
            
            
            let percent = habit.percentCompleted(on: day.date)
            if percent > 0 {
               if percent == 1 && Calendar.current.isDateInToday(day.date) {
                  Image(systemName: "checkmark.circle.fill")
                     .resizable()
                     .aspectRatio(contentMode: .fit)
                     .foregroundColor(.green)
                     .frame(width: circleSize, height: circleSize)
                     .reverseMask {
                        if percent < 1 {
                           RingCutout(from: 0, to: percent, clockwise: false)
                        }
                     }
               } else {
                  ZStack {
                     Circle()
                        .foregroundColor(.systemGray6)
                        .frame(width: circleSize, height: circleSize)
                     Circle()
                        .foregroundColor(.green)
                        .frame(width: circleSize, height: circleSize)
                        .reverseMask {
                           if percent < 1 {
                              RingCutout(from: 0, to: percent, clockwise: false)
                                 .frame(width: circleSize + 1, height: circleSize + 1)
                           }
                        }
                  }
               }
            } else {
               if Calendar.current.isDateInToday(day.date) {
                  Circle()
                     .stroke(.gray, style: .init(lineWidth: 1))
                     .frame(width: circleSize, height: circleSize)
               } else {
                  Circle()
                     .foregroundColor(.systemGray3)
                     .frame(width: circleSize, height: circleSize)
               }
            }
            
         }
      }
      
   }
}

struct CalendarDayView_Previews: PreviewProvider {
   
   static var previews: some View {
      
      let context = CoreDataManager.previews.mainContext
      
      let yesterday3 = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
      let yesterday2 = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
      let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
      let today = Date()
      
      let h1 = try? Habit(context: context, name: "A")
      h1?.changeFrequency(to: .timesPerDay(3), on: yesterday3)
      
      let _ = try? Habit(context: context, name: "B")
      
      let habits = Habit.habits(from: context)
      
      let habit1 = habits.first!
      let habit2 = habits.last!
      
      
      let dayView3 = Day(date: yesterday3, isWithinDisplayedMonth: true)
      let dayView2 = Day(date: yesterday2, isWithinDisplayedMonth: true)
      let dayView1 = Day(date: yesterday, isWithinDisplayedMonth: true)
      let dayView0 = Day(date: today, isWithinDisplayedMonth: true)
      
      
      h1?.markCompleted(on: yesterday2)
      h1?.markCompleted(on: yesterday)
      h1?.markCompleted(on: yesterday)
      h1?.markCompleted(on: yesterday)
      h1?.markCompleted(on: today)
      h1?.markCompleted(on: today)
      h1?.markCompleted(on: today)
      //      h1?.markCompleted(on: today)
      
      let fontSize: CGFloat = 19
      let circleSize: CGFloat = 30
      
      return (
         HStack {
            CalendarDayView(habit: habit1,
                            day: dayView3,
                            fontSize: fontSize,
                            circleSize: circleSize)
            
            CalendarDayView(habit: habit1,
                            day: dayView2,
                            fontSize: fontSize,
                            circleSize: circleSize)
            
            CalendarDayView(habit: habit1,
                            day: dayView1,
                            fontSize: fontSize,
                            circleSize: circleSize)
            
            CalendarDayView(habit: habit1,
                            day: dayView0,
                            fontSize: fontSize,
                            circleSize: circleSize)
            
            
            CalendarDayView(habit: habit2,
                            day: dayView0,
                            fontSize: fontSize,
                            circleSize: circleSize)
            
         }
         
      )
   }
}
