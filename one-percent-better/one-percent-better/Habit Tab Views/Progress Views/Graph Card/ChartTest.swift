//
//  ChartTest.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 9/29/22.
//

import SwiftUI
import Charts

struct ChartTest: View {
    
    struct MonthlyHoursOfSunshine: Identifiable {
        var date: Date
        var hoursOfSunshine: Double
        var id = UUID()

        init(month: Int, hoursOfSunshine: Double) {
            let calendar = Calendar.autoupdatingCurrent
            self.date = calendar.date(from: DateComponents(year: 2020, month: month))!
            self.hoursOfSunshine = hoursOfSunshine
        }
    }

    var data: [MonthlyHoursOfSunshine] = [
        MonthlyHoursOfSunshine(month: 1, hoursOfSunshine: 74),
        MonthlyHoursOfSunshine(month: 2, hoursOfSunshine: 99),
        // ...
        MonthlyHoursOfSunshine(month: 12, hoursOfSunshine: 62)
    ]

    var body: some View {
        Chart(data) {
            LineMark(
                x: .value("Month", $0.date),
                y: .value("Hours of Sunshine", $0.hoursOfSunshine)
            )
        }
        .frame(width: 200)
        .frame(height: 100)
    }
}

struct ChartTest_Previews: PreviewProvider {
    static var previews: some View {
        ChartTest()
    }
}
