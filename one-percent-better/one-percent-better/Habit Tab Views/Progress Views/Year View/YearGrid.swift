//
//  YearGrid.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 6/12/23.
//

import SwiftUI
import Combine

enum YearViewGridCell {
    case weekdayLabel(Weekday)
    case daySquare(Int)
    case emptySquare
}

class YearViewIndexer {
    let year: Int
    
    /// The user preference for the start of the week
    var startOfWeek: Weekday
    
    private var cancelBag: Set<AnyCancellable> = []
    
    /// 1 column for the weekday labels
    /// 53 columns for the days because 52 columns gives 364 days but a year has at least 365 days
    let numColumns = 54
    
    /// Returns the number of days in a given year.
    var numberOfDaysInYear: Int {
        year.isLeapYear ? 366 : 365
    }
    
    init(year: Int) {
        self.year = year
        self.startOfWeek = StartOfWeekModel.shared.startOfWeek
        
        // Subscribe to start of week from StartOfWeekModel
        StartOfWeekModel.shared.startOfWeekSubject.sink { newWeekday in
            self.startOfWeek = newWeekday
        }
        .store(in: &cancelBag)
    }
    
    // Indices run as:
    // 0     1   2   3   4 ...
    // 54   55  56  57  58 ...
    // 108 109 110 111 112 ...
    // ...
    func getCell(for gridIndex: Int) -> YearViewGridCell {
        let row = gridIndex / numColumns
        let column = gridIndex % numColumns
        
        switch (row, column) {
        case (let row, 0):
            return .weekdayLabel(Weekday.weekday(for: row))
        default:
            // Adjust for weekday column
            let dayColumn = column - 1
            // Convert to day grid index
            let dayIndex = row + (dayColumn * 7)
            // Offset for january 1st offset and start of the week preference
            let offsetIndex = dayIndex - januaryFirstOffset(year: year)
            
            // Before the 1st of Jan
            guard offsetIndex >= 0 else {
                return .emptySquare
            }

            // After today's index
            guard offsetIndex <= daysOffsetFromYearStart(to: Date()) else {
                return .emptySquare
            }

            // Past number of days in this year
            let totalDays = numberOfDaysInYear - 1
            guard offsetIndex <= totalDays else {
                return .emptySquare
            }
            
            return .daySquare(offsetIndex)
        }
    }
    
    /// Returns the offset in days from January 1st of a given year for a specified date.
    ///
    /// - Parameters:
    ///   - date: The date to calculate the offset for.
    ///   - year: The year from which to calculate the offset.
    /// - Returns: The offset in days from the start of the specified year.
    func daysOffsetFromYearStart(to date: Date) -> Int {
        let startOfYear = Cal.date(from: DateComponents(year: year))!
        return Cal.dateComponents([.day], from: startOfYear, to: date).day!
    }
    
    /// Which day january 1st falls on this year
    /// - Parameter year: The year
    /// - Returns: Integer describing which weekday relative to users start of week preference
    func januaryFirstOffset(year: Int) -> Int {
        let firstOfJan = Cal.date(from: DateComponents(calendar: Cal, year: year, month: 1, day: 1))!
        return firstOfJan.weekdayIndex
    }
}

struct YearGrid: View {
    
    @ObservedObject var sowm = StartOfWeekModel.shared
    @State private var squareSize: CGFloat = 0
    
    var opacities: [Double]
    var yearViewIndexer: YearViewIndexer
    
    var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(minimum: 1, maximum: .infinity), spacing: 1, alignment: .top), count: yearViewIndexer.numColumns)
    }
    
    init(year: Int, opacities: [Double]) {
        self.opacities = opacities
        yearViewIndexer = YearViewIndexer(year: year)
    }
    
    var body: some View {
        VStack(spacing: 5) {
            
            HStack {
                ForEach(Month.allCases) { month in
                    Text(month.shortDescription)
                        .font(.system(size: squareSize + 6))
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                    Spacer()
                }
            }
            .padding(.leading, squareSize)
            
            LazyVGrid(columns: columns, spacing: 1) {
                                
                ForEach(0 ..< yearViewIndexer.numColumns * 7, id: \.self) { gridIndex in
                    switch yearViewIndexer.getCell(for: gridIndex) {
                    case .weekdayLabel(let weekday):
                        Text(weekday.letter)
                            .font(.system(size: squareSize))
                            .foregroundColor(.secondary)
                            .fontWeight(.medium)
                            .frame(width: squareSize, height: squareSize, alignment: .center)
                            .padding(.trailing, 5)
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
