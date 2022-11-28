//
//  YearView.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 6/25/22.
//

import SwiftUI

struct YearView: View {
   
   let insets: CGFloat = 15
   let spacing: CGFloat = 1
   
   @State private var yearHeight: CGFloat = 0
   
   var body: some View {
      
      CardView {
         VStack(spacing: 0) {
//            HStack {
//               CardTitle("2022")
//               Spacer()
//            }
//            .padding(.horizontal, 15)
            
            GeometryReader { geo in
               let squareWidth: CGFloat = ((geo.size.width - (51 * spacing)) / 52.0)
               let rows: [GridItem] = Array(repeating: GridItem(.fixed(squareWidth), spacing: spacing, alignment: .top), count: 7)
               let height: CGFloat = 7 * squareWidth + 6 * spacing
               
               LazyHGrid(rows: rows, spacing: 1) {
                  CompletedSquare()
               }
               .frame(height: max(0, height))
               .overlay(
                  GeometryReader { geo in
                     Color.clear.onAppear {
                        self.yearHeight = geo.size.height
                     }
                  }
               )
            }
            .padding(.horizontal, 5)
            .frame(height: yearHeight)
//            .padding(.vertical, 10)
         }
      }
   }
}

struct YearView_Previews: PreviewProvider {
   
   static func data() -> Habit {
      let context = CoreDataManager.previews.mainContext
      
      let day0 = Date()
      let h1 = try? Habit(context: context, name: "Swimming")
      h1?.markCompleted(on: day0)
      h1?.changeFrequency(to: .timesPerDay(3), on: Cal.date(byAdding: .day, value: -364, to: day0)!)
      
      for _ in 0 ..< 730 {
         let rand = Int.random(in: 0 ..< 364)
         h1?.markCompleted(on: Cal.date(byAdding: .day, value: -rand, to: day0)!)
      }
      
      let habits = Habit.habits(from: context)
      return habits.first!
   }
   
   static var previews: some View {
      Background {
         VStack(spacing: 20) {
            YearView()
               .environmentObject(data())
         }
      }
   }
}

struct CompletedSquare: View {
   
   @EnvironmentObject var habit: Habit
   
   let today = Date()
   
   func opacity(on curDay: Date) -> Double {
      var opacity: Double
      switch habit.frequency(on: curDay) {
      case .timesPerDay(let n):
         opacity = Double(habit.timesCompleted(on: curDay)) / Double(n)
      case .daysInTheWeek:
         opacity = Double(1)
      case nil:
         opacity = 0
      }
      return opacity
   }
   
   var body: some View {
      ForEach(0 ..< 364) { i in
         let j = 363 - i
         let curDay = Cal.date(byAdding: .day, value: -j, to: today)!
         let isCompleted = habit.timesCompleted(on: curDay) >= 1
         
         
         let opacity = opacity(on: curDay)
         
         Rectangle()
            .fill(isCompleted ? .green.opacity(opacity) : .systemGray5)
            .aspectRatio(1, contentMode: .fit)
         
      }
   }
}
