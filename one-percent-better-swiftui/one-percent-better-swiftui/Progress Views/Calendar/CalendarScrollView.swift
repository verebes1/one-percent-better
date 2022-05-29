//
//  CalendarScrollView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/27/22.
//

import SwiftUI

struct CalendarScrollView: View {
    
    @EnvironmentObject var habit: Habit
    @EnvironmentObject var calendar: CalendarModel
    
    @State var currentPage = 0
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 7)
    
    
    var body: some View {
        VStack {
            Text("Num months: \(calendar.numMonthsSinceStart)")
            TabView(selection: $currentPage) {
                let numMonths = calendar.numMonthsSinceStart
                ForEach(0 ..< numMonths, id: \.self) { i in
                    LazyVGrid(columns: columns, spacing: 10) {
                        let offset = numMonths - 1 - i
                        ForEach(calendar.backXMonths(x: offset), id: \.date) { day in
                            CalendarDayView(day: day,
                                            width: 23,
                                            height: 23)
                            .padding(.vertical, 2)
                        }
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(width: UIScreen.main.bounds.width - 20, height: 270)
            .onAppear {
                currentPage = calendar.numMonthsSinceStart - 1
            }
            
            Button("Mark Last Month Completed") {
                let x = currentPage - calendar.numMonthsSinceStart
                let lastMonth = Calendar.current.date(byAdding: .month, value: x, to: Date())!
                habit.markCompleted(on: lastMonth)
            }
        }
    }
}

struct CalendarScrollView_Previews: PreviewProvider {
    static var previews: some View {
        let context = CoreDataManager.previews.persistentContainer.viewContext
        
        let h1 = try? Habit(context: context, name: "Jumping Jacks")
        h1?.markCompleted(on: Date())
        let oneMonthBack = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        h1?.markCompleted(on: oneMonthBack)
        let twoMonthsBack = Calendar.current.date(byAdding: .month, value: -2, to: Date())!
        h1?.markCompleted(on: twoMonthsBack)

        let habits = Habit.updateHabitList(from: context)

        let habit = habits.first!
        
        let calendar = CalendarModel(habit: habit)
        
        return(
        CardView {
            CalendarScrollView()
                .environmentObject(habit)
                .environmentObject(calendar)
                .environment(\.managedObjectContext, context)
//                .border(.black, width: 1)
        })
    }
}
