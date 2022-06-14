//
//  GraphData.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/14/22.
//

import Foundation

class GraphData {
    
    var graphTracker: GraphTracker
    
    var startDate: Date!
    var endDate: Date!
    var numDays: Int!
    
    // All dates and values for
    var allDates: [Date]
    var allValues: [Double]
    
    // Data in the range [startDate, endDate]
    var dates: [Date]! = []
    var values: [Double]! = []
    
    // Data point just before range, and after range
    // This is needed to extend line past graph
    var beforeDate: Date?
    var beforeValue: Double?
    var afterDate: Date?
    var afterValue: Double?
    
    init(graphTracker: GraphTracker) {
        self.graphTracker = graphTracker
        self.allDates = graphTracker.dates
        self.allValues = []
        for value in graphTracker.values {
            guard let d = Double(value) else {
                fatalError("Can't convert to doubles for graph")
            }
            self.allValues.append(d)
        }
    }
    
    func updateRange(endDate: Date, numDaysBefore: Int) {
        numDays = numDaysBefore
        
        let end = Calendar.current.startOfDay(for: endDate)
        self.endDate = Calendar.current.date(byAdding: .day, value: 1, to: end)!
        
        let start = Calendar.current.date(byAdding: .day, value: -(numDays - 1), to: endDate)!
        startDate = Calendar.current.startOfDay(for: start)
        
        beforeDate = nil
        beforeValue = nil
        afterDate = nil
        afterValue = nil
        
        // Get data in range [startDate, endDate]
        self.dates = []
        self.values = []
        if var index = allDates.firstIndex(where: {$0 >= startDate}) {
            
            // Data point before
            if index != 0 {
                beforeDate = allDates[index - 1]
                beforeValue = allValues[index - 1]
            }
            
            // Data points in range
            while index < allDates.count && allDates[index] < self.endDate {
                dates.append(allDates[index])
                values.append(allValues[index])
                index += 1
            }
            
            // Data point after
            if index < allDates.count {
                // Use [index] and not [index + 1] because in the while loop above,
                // the last data point in range will increase the index to the next point
                afterDate = allDates[index]
                afterValue = allValues[index]
            }
        }
    }
}
