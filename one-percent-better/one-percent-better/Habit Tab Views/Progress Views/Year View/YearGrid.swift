//
//  YearGrid.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 6/12/23.
//

import SwiftUI

enum YearViewGridCell {
    //   case monthLabel(Int)
    case daySquare(Int)
    case emptySquare
}

class YearViewIndexer {
    let year: Int
    var monthDays = [0, 32, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335]
    
    init(year: Int) {
        self.year = year
    }
    
    // Indices run as:
    // 0     1   2   3   4 ...
    // 53   54  55  56  57 ...
    // 106 107 108 109 110 ...
    func getCell(for gridIndex: Int) -> YearViewGridCell {
        let dayIndex = dayIndex(from: gridIndex)
        if dayIndex.display {
            return .daySquare(dayIndex.index)
        } else {
            return .emptySquare
        }
    }
    
    func dayIndex(from gridIndex: Int) -> (index: Int, display: Bool) {
        let column = gridIndex % 53
        let row = gridIndex / 53
        var realIndex = row + 7 * column
        let januaryOffset = januaryFirstOffset(year: year)
        realIndex = realIndex - januaryOffset
        
        // Before the 1st of Jan
        guard realIndex >= 0 else {
            return (realIndex, false)
        }
        
        // After today's index
        let todayIndex = daysOffsetFromYearStart(date: Date())
        guard realIndex <= todayIndex else {
            return (realIndex, false)
        }
        
        // Past number of days in this year
        let totalDays = numberOfDaysInYear() - 1
        guard realIndex <= totalDays else {
            return (realIndex, false)
        }
        
        return (realIndex, true)
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
    
    /// Returns the offset in days from January 1st of a given year for a specified date.
    ///
    /// - Parameters:
    ///   - date: The date to calculate the offset for.
    ///   - year: The year from which to calculate the offset.
    /// - Returns: The offset in days from the start of the specified year.
    func daysOffsetFromYearStart(date: Date) -> Int {
        let calendar = Calendar.current
        let startOfYear = calendar.date(from: DateComponents(year: year))!
        return calendar.dateComponents([.day], from: startOfYear, to: date).day!
    }
    
    /// Which day january 1st falls on this year
    /// - Parameter year: The year
    /// - Returns: Integer describing which weekday, 0 for Monday, 1 for Tuesday, etc.
    func januaryFirstOffset(year: Int) -> Int {
        let firstOfJan = Cal.date(from: DateComponents(calendar: Cal, year: year, month: 1, day: 1))!
        return (firstOfJan.weekdayIndex + 6) % 7
    }
}

struct YearGrid: View {
    
    var opacities: [Double]
    @State private var squareSize: CGFloat = 0
    
    var yearViewIndexer: YearViewIndexer
    
    var weekdayLabels = ["M", "T", "W", "T", "F", "S", "S"]
    var monthLabels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    
    init(year: Int, opacities: [Double]) {
        self.opacities = opacities
        yearViewIndexer = YearViewIndexer(year: year)
    }
    
    var body: some View {
        VStack(spacing: 5) {
            
            HStack {
                ForEach(monthLabels, id: \.self) { month in
                    Text(month)
                        .font(.system(size: squareSize + 6))
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                    Spacer()
                }
            }
            
            let columns: [GridItem] = Array(repeating: GridItem(.flexible(minimum: 1, maximum: .infinity), spacing: 1, alignment: .top), count: 53)
            LazyVGrid(columns: columns, spacing: 1) {
                
                // 53 columns of 7 = 371 items (52 columns gives only 364 days but a year has 365 days, and 366 on a leap year)
                
                ForEach(0 ..< 53 * 7) { gridIndex in
                    switch yearViewIndexer.getCell(for: gridIndex) {
                    case .emptySquare:
                        Color.clear
                            .frame(width: squareSize, height: squareSize, alignment: .leading)
                    case .daySquare(let i):
                        ZStack {
                            Rectangle()
                                .fill(.clear)
                                .aspectRatio(1, contentMode: .fit)
                                .overlay(
                                    GeometryReader { geo in
                                        Color.clear.onAppear {
                                            self.squareSize = max(0, geo.size.height)
                                        }
                                    }
                                )
                            YearGridCell(color: .green, size: squareSize, percent: opacities[i])
                        }
                    }
                }
            }
        }
    }
}

struct GrowingSquareGrid_Previews: PreviewProvider {
    static var previews: some View {
        YearGrid(year: 2023, opacities: Array(repeating: 0, count: 366))
    }
}
