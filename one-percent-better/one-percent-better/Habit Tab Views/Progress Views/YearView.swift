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
   
   @State private var selectedYear = 2022
   
   var body: some View {
      
      CardView {
         VStack(spacing: 0) {
            Spacer().frame(height: 4)
            HStack {
               Spacer()
               Menu {
                  MenuItemWithCheckmark(value: 2021,
                                        selection: $selectedYear)
                  MenuItemWithCheckmark(value: 2022,
                                        selection: $selectedYear)
               } label: {
                  CapsuleMenuButtonLabel(label: {
                     Text(String(selectedYear))
                  }, color: .cardColorLighter)
               }
               Spacer().frame(width: 7)
            }
            
            GeometryReader { geo in
               let squareWidth: CGFloat = ((geo.size.width - (51 * spacing)) / 52.0)
               let rows: [GridItem] = Array(repeating: GridItem(.fixed(squareWidth), spacing: spacing, alignment: .top), count: 7)
               let height: CGFloat = 7 * squareWidth + 6 * spacing
               
               LazyHGrid(rows: rows, spacing: 1) {
//                  CompletedSquare()
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
            .padding(3)
         }
      }
   }
}

//struct YearViewPreview: View {
//
//   let id = UUID()
//
//   func data() -> Habit? {
//      let context = CoreDataManager.previews.mainContext
//
//      let day0 = Date()
//      let h1 = try? Habit(context: context, name: "L", frequency: .timesPerDay(3), id: id)
////      h1?.markCompleted(on: day0)
////      h1?.changeFrequency(to: .timesPerDay(3), on: Cal.date(byAdding: .day, value: -364, to: day0)!)
////
////      for _ in 0 ..< 730 {
////         let rand = Int.random(in: 0 ..< 364)
////         h1?.markCompleted(on: Cal.date(byAdding: .day, value: -rand, to: day0)!)
////      }
//
//      let habits = Habit.habits(from: context)
//      return habits.first!
//   }
//
//   var habit: Habit?
//
//   init() {
//      self.habit = data()
//   }
//
//   var body: some View {
////      let habit = data()
//      return (
//         Background {
//            VStack(spacing: 20) {
//               YearView()
//                  .environment(\.managedObjectContext, CoreDataManager.previews.mainContext)
//                  .environmentObject(habit!)
//            }
//         }
//      )
//   }
//}
//
//struct YearView_Previews: PreviewProvider {
//   static var previews: some View {
//      YearViewPreview()
//   }
//}

struct CompletedSquare: View {
   
   @Environment(\.colorScheme) var scheme
   
   @EnvironmentObject var habit: Habit
   
   let today = Date()
   
   @State private var opacities: [Double] = Array(repeating: 0, count: 364)
//
   func opacity(on curDay: Date) -> Double {
      var opacity: Double
      switch habit.frequency(on: curDay) {
      case .timesPerDay(let n):
         opacity = Double(habit.timesCompleted(on: curDay)) / Double(n)
      case .specificWeekdays, .timesPerWeek:
         opacity = Double(1)
      case nil:
         opacity = 0
      }
      return opacity
   }
   
   var body: some View {
      ForEach(0 ..< 364) { i in
         let notFilledColor: Color = scheme == .light ? .systemGray5 : .systemGray3
         Rectangle()
            .fill(opacities[i] != 0 ? .green/*.opacity(opacities[i])*/ : notFilledColor)
            .aspectRatio(1, contentMode: .fit)
      }
      .task {
         for i in 0 ..< 364 {
            let j = 363 - i
            let curDay = Cal.date(byAdding: .day, value: -j, to: today)!
            let opacity = opacity(on: curDay)
            opacities[i] = opacity
         }
      }
   }
}
