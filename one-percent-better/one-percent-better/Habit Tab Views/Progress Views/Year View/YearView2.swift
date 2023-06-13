//
//  YearView2.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 6/10/23.
//

import SwiftUI

struct YearView2: View {
   
   @Binding var opacities: [Double]
   @State private var yearHeight: CGFloat = 0
   @State private var weekdaysWidth: CGFloat = 0
   
   let insets: CGFloat = 15
   let spacing: CGFloat = 1
   
   var weekdays = ["M", "T", "W", "T", "F", "S", "S"]
   var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
   var monthDays = [0, 32, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335]
   
   
   func isMonthColumn(colIndex: Int) -> Int? {
      let index =  monthDays.firstIndex { colIndex >= $0 && colIndex - 7 < $0 }
      return index
   }
   
   var body: some View {
      VStack {
//         Text("weekdaysWidth: \(weekdaysWidth)")
//         Text("yearHeight: \(yearHeight)")
         GeometryReader { geo in
            let totalWidth = geo.size.width
            let gridWidth = totalWidth - 5
            let squareSize: CGFloat = ((gridWidth - (53 * spacing)) / 54.0)
            let rows: [GridItem] = Array(repeating: GridItem(.fixed(squareSize), spacing: spacing, alignment: .top), count: 8)
            let height: CGFloat = 8 * squareSize + 7 * spacing + 3
            
            // 54 columns of 7 = 378 items
            // 1 column for weekday labels
            // 53 columns for days (52 columns gives only 364 days but a year has 365 days, and 366 on a leap year)
            
            // 54 columns of 8 = 432 items
            // 1 column for weekday labels
            // 1 row for month labels
            // 53 columns for days (52 columns gives only 364 days but a year has 365 days, and 366 on a leap year)
            
            VStack {
               LazyHGrid(rows: rows, spacing: spacing) {
                  ForEach(0 ..< 432) { i in
                     if i < 8 {
                        if i == 0 {
                           Color.clear
                              .frame(width: squareSize, height: squareSize)
                        } else {
//                           Color.clear
//                              .frame(width: squareSize, height: squareSize)
                           Text(weekdays[i-1])
                              .font(.system(size: squareSize))
                              .padding(.trailing, squareSize / 3)
                        }
                     } else if i % 8 == 0 {
                        let realOffset = ((i - 8) / 8) * 7
                        if let index = isMonthColumn(colIndex: realOffset) {
//                           Color.clear
//                              .frame(width: squareSize, height: squareSize)
                           Text(months[index])
                              .font(.system(size: squareSize + 1))
                              .fixedSize()
                              .frame(width: squareSize, height: squareSize + 3, alignment: .leading)
                              .offset(y: -3)
                        } else {
                           Color.clear
                              .frame(width: squareSize, height: squareSize)
                        }
                     } else {
//                        YearGridCell(color: .green, size: squareSize, percent: opacities[i])
                        let realIndex = i - 9
                        
                        Text("\(realIndex)")
                           .font(.system(size: squareSize))
                     }
                  }
//                  .border(.red)
               }
               .frame(height: height)
               .overlay(
                  GeometryReader { geo in
                     Color.clear.onAppear {
                        self.yearHeight = geo.size.height
                     }
                  }
               )
            }
         }
         .frame(height: yearHeight)
//         .border(.blue)
      }
//      .border(.black)
      .padding()
   }
}

struct YearView2Previewer: View {
   
   @State private var opacities: [Double] = Array(repeating: 0.0, count: 432)
   
   var body: some View {
      YearView2(opacities: $opacities)
   }
}

struct YearView2_Previews: PreviewProvider {
   static var previews: some View {
      YearView2Previewer()
   }
}
