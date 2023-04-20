//
//  YearView.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 6/25/22.
//

import SwiftUI

struct YearView: View {
   
   @EnvironmentObject var habit: Habit
   
   @State private var yearHeight: CGFloat = 0
   @State private var selectedYear = Cal.dateComponents([.year], from: Date()).year!
   
   let insets: CGFloat = 15
   let spacing: CGFloat = 1

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
               Spacer()
               Menu {
                  ForEach(years, id: \.self) { year in
                     MenuItemWithCheckmark(value: year,
                                           selection: $selectedYear)
                  }
                  
               } label: {
                  CapsuleMenuButtonLabel(label: {
                     Text(String(selectedYear))
                  }, color: .cardColorLighter)
               }
               .padding(.vertical, 4)
               .padding(.horizontal, 7)
            }
            
            GeometryReader { geo in
               let squareWidth: CGFloat = ((geo.size.width - (51 * spacing)) / 52.0)
               let rows: [GridItem] = Array(repeating: GridItem(.fixed(squareWidth), spacing: spacing, alignment: .top), count: 7)
               let height: CGFloat = 7 * squareWidth + 6 * spacing
               
               LazyHGrid(rows: rows, spacing: 1) {
                  CompletedSquare(year: $selectedYear)
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
   
   @State private var opacities: [Double] = Array(repeating: 0, count: 364)
   
   @Binding var year: Int
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
      print("Fetching opacities")
      let firstOfJan = Cal.date(from: DateComponents(calendar: Cal, year: year, month: 1, day: 1))!
      for i in 0 ..< 364 {
         let curDay = Cal.date(byAdding: .day, value: i, to: firstOfJan)!
         opacities[i] = opacity(on: curDay)
      }
   }
   
   var body: some View {
      ForEach(0 ..< 364) { i in
         let notFilledColor: Color = scheme == .light ? .systemGray5 : .systemGray3
         Rectangle()
            .fill(opacities[i] != 0 ? .green.opacity(opacities[i]) : notFilledColor)
            .aspectRatio(1, contentMode: .fit)
      }
      .animation(.easeInOut(duration: 0.15), value: opacities)
      .onChange(of: year) { newValue in
         Task { fetchOpacities() }
      }
      .task {
         fetchOpacities()
      }
   }
}
