//
//  YearView.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 6/25/22.
//

import SwiftUI

enum YearViewRoute: Hashable {
   case viewAll
}

struct YearView: View {
   
   var habit: Habit
   
   @State private var selectedYear = Cal.dateComponents([.year], from: Date()).year!
   
   var years: [Int] {
      let startYear = Cal.dateComponents([.year], from: habit.startDate).year!
      let thisYear = Cal.dateComponents([.year], from: Date()).year!
      var years: [Int] = []
      for i in startYear ... thisYear {
         years.append(i)
      }
      return years
   }
   
   var body: some View {
      CardView {
         VStack(spacing: 0) {
            HStack {
               Menu {
                  ForEach(years, id: \.self) { year in
                     MenuItemWithCheckmark(value: year,
                                           selection: $selectedYear)
                  }
                  
               } label: {
                  CapsuleMenuButtonLabel(label: {
                     Text(String(selectedYear))
                        .font(.system(size: 13))
                  }, color: .cardColorLighter)
               }
               .padding(.vertical, 4)
               .padding(.horizontal, 7)
               
               Spacer()
               
               NavigationLink(value: YearViewRoute.viewAll) {
                  HStack {
                     Text("View All")
                     Image(systemName: "chevron.right")
                  }
                  .font(.system(size: 14))
                  .padding(.trailing, 10)
               }
            }
            .padding(.bottom, 4)
            
            YearGridWrapper(habit: habit, year: selectedYear)
               .padding(.horizontal, 5)
               .padding(.bottom, 3)
         }
      }
      .navigationDestination(for: YearViewRoute.self) { route in
         switch route {
         case .viewAll:
            YearViewAllYears(habit: habit, years: years.reversed())
         }
      }
   }
}

struct YearViewPreview: View {

   let id = UUID()

   func data() -> Habit {
      let context = CoreDataManager.previews.mainContext

      let day0 = Date()
      let h1 = try? Habit(context: context, name: "L", frequency: .timesPerDay(3), id: id)
      h1?.markCompleted(on: day0)
      h1?.changeFrequency(to: .timesPerDay(2), on: Cal.date(byAdding: .day, value: -364, to: day0)!)

      for _ in 0 ..< 10 {
         let rand = Int.random(in: 0 ..< 364)
         h1?.markCompleted(on: Cal.date(byAdding: .day, value: -rand, to: day0)!)
      }

      let habits = Habit.habits(from: context)
      return habits.first!
   }

   var habit: Habit!

   init() {
      self.habit = data()
   }

   var body: some View {
      let habit = data()
      return (
         Background {
            VStack(spacing: 20) {
               YearView(habit: habit)
                  .environment(\.managedObjectContext, CoreDataManager.previews.mainContext)
            }
         }
      )
   }
}

struct YearView_Previews: PreviewProvider {
   static var previews: some View {
      YearViewPreview()
   }
}

struct YearGridWrapper: View {
   
   @Environment(\.colorScheme) var scheme
   var habit: Habit
   
   @State private var opacities: [Double] = Array(repeating: 0, count: 366)
   
   var year: Int
   let today = Date()

   func opacity(on curDay: Date) -> Double {
      guard let freq = habit.frequency(on: curDay) else { return 0 }
      switch freq {
      case .timesPerDay(let n):
         return Double(habit.timesCompleted(on: curDay)) / Double(n)
      case .specificWeekdays, .timesPerWeek:
         return habit.wasCompleted(on: curDay) ? 1 : 0
      }
   }
   
   @MainActor func fetchOpacities() {
      let firstOfJan = Cal.date(from: DateComponents(calendar: Cal, year: year, month: 1, day: 1))!
      for i in 0 ..< numberOfDaysInYear() {
         let curDay = Cal.date(byAdding: .day, value: i, to: firstOfJan)!
         opacities[i] = opacity(on: curDay)
      }
   }
   
   /// Returns the number of days in a given year.
   ///
   /// - Parameter year: The year to calculate the number of days for.
   /// - Returns: The number of days in the specified year.
   func numberOfDaysInYear() -> Int {
       if (year % 4 == 0 && year % 100 != 0) || year % 400 == 0 {
           return 366 // leap year
       } else {
           return 365 // common year
       }
   }
   
   var body: some View {
      YearGrid(year: year, opacities: opacities)
      .animation(.easeInOut(duration: 0.15), value: opacities)
      .onChange(of: year) { newValue in
         Task { fetchOpacities() }
      }
      .task {
         fetchOpacities()
      }
   }
}
