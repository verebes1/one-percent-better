//
//  YearViewAllYears.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 6/13/23.
//

import SwiftUI

struct YearViewAllYears: View {
   var habit: Habit
   var years: [Int]
   
   var body: some View {
      Background {
         ScrollView {
            Spacer().frame(height: 10)
            ForEach(0 ..< years.count, id: \.self) { i in
               VStack(spacing: 5) {
                  HStack {
                     Text("\(String(years[i]))")
                     Spacer()
                  }
                  YearGridWrapper(habit: habit, year: years[i])
                     .padding(.horizontal, 5)
                     .padding(.bottom, 8)
               }
               .padding(.horizontal, 10)
            }
         }
      }
      .navigationBarTitleDisplayMode(.inline)
   }
}

struct YearViewAllYearsPreview: View {

   let id = UUID()

   func data() -> Habit {
      let context = CoreDataManager.previews.mainContext

      let day0 = Date()
      let h1 = try? Habit(context: context, name: "L", frequency: .timesPerDay(2), id: id)
      h1?.markCompleted(on: day0)
      h1?.changeFrequency(to: .timesPerDay(2), on: Cal.date(byAdding: .day, value: -364, to: day0)!)

      for _ in 0 ..< 100 {
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
         VStack(spacing: 20) {
            YearViewAllYears(habit: habit, years: [2023, 2022])
               .environment(\.managedObjectContext, CoreDataManager.previews.mainContext)
         }
      )
   }
}

struct YearViewAllYears_Previews: PreviewProvider {
   static var previews: some View {
      YearViewAllYearsPreview()
   }
}
