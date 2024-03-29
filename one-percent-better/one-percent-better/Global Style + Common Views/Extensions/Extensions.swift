//
//  Extensions.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 12/1/21.
//

import UIKit
import CoreData
import SwiftUI

// MARK: - UIViewController

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - Collection

extension Collection where Iterator.Element == Float {
    var doubleArray: [Double] {
        return compactMap { Double($0) }
    }
}

extension Collection where Iterator.Element == Int {
    var doubleArray: [Double] {
        return compactMap { Double($0) }
    }
}

// MARK: - NSOrderedSet

extension NSOrderedSet {
    func asArray<T>() -> [T] {
        return self.array as? [T] ?? []
    }
}

// MARK: - Calendar

extension Calendar {
    func numberOfDays(from startDate: Date, to endDate: Date) -> Int {
        dateComponents([.day], from: startDate.startOfDay, to: endDate.startOfDay).day!
    }
    
    func add(days i: Int, to date: Date = Date()) -> Date {
        Cal.date(byAdding: .day, value: i, to: date)!
    }
    
    func add(years i: Int, to date: Date = Date()) -> Date {
        Cal.date(byAdding: .year, value: i, to: date)!
    }
    
    /// Get the most recent day which matches this weekday, strictly before a date
    /// - Parameters:
    ///   - weekday: The desired weekday
    ///   - date: Going backward from this date
    ///   - includingDate: Whether or not to include date in the search backward
    /// - Returns: The most recent date which matches this weekday before the date
    func mostRecent(weekday: Weekday, before date: Date = Date(), includingDate: Bool = false) -> Date {
        var diff = Weekday.positiveDifference(from: weekday, to: Weekday(date))
        if diff == 0 && !includingDate {
            diff = 7
        }
        return Cal.add(days: -diff, to: date)
    }
    
    func date(time: DateComponents, dayMonthYear: Date) -> Date {
        var dayAndTime = time
        let dayComponents = Cal.dateComponents([.day, .month, .year,], from: dayMonthYear)
        dayAndTime.calendar = Cal
        dayAndTime.day = dayComponents.day
        dayAndTime.month = dayComponents.month
        dayAndTime.year = dayComponents.year
        let newDate = Cal.date(from: dayAndTime)!
        return newDate
    }
}

public var Cal = Calendar.autoupdatingCurrent


// MARK: - Double

extension Double {
    func hasDecimals() -> Bool {
        let decimals = self - Double(Int(self))
        return decimals != 0
    }
}

// MARK: - CodingUserInfoKey

extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
}


// MARK: - SwiftUI

prefix func ! (value: Binding<Bool>) -> Binding<Bool> {
    Binding<Bool>(
        get: { !value.wrappedValue },
        set: { value.wrappedValue = !$0 }
    )
}

// MARK: - Image

extension Image {
    func fitToFrame() -> some View {
        return self
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

// MARK: - View

extension View {
    func printType() -> some View {
        print(type(of: self))
        return self
    }
    
    func printChanges() -> some View {
        let _ = Self._printChanges()
        return self
    }
}

// MARK: - RandomAccessCollection

extension RandomAccessCollection {
    /// Finds such index N that predicate is true for all elements up to
    /// but not including the index N, and is false for all elements
    /// starting with index N.
    /// Behavior is undefined if there is no such N.
    func binarySearch(predicate: (Iterator.Element) -> Bool) -> Index? {
        var low = startIndex
        var high = endIndex
        while low != high {
            let mid = index(low, offsetBy: distance(from: low, to: high) / 2)
            if predicate(self[mid]) {
                low = index(after: mid)
            } else {
                high = mid
            }
        }
        return (low as! Int) < count ? low : nil
    }
}

extension RandomAccessCollection where Element == Date, Index == Int {
    func sameDayBinarySearch(for date: Date) -> Index?  {
        guard let i = binarySearch(predicate: { $0 < Cal.startOfDay(for: date) }) else {
            return nil
        }
        if Cal.isDate(date, inSameDayAs: self[i]) {
            return i
        } else {
            return nil
        }
    }
    
    /// Binary searches this array for the last index where date <= array[i]
    func lessThanOrEqualSearch(for date: Date) -> Index?  {
        guard let i = binarySearch(predicate: { $0.startOfDay <= date.startOfDay }) else {
            if let last = self.last,
               last.startOfDay <= date.startOfDay {
                return self.count - 1
            } else {
                return nil
            }
        }
        
        let j = i - 1
        if j >= 0, self[j].startOfDay <= date.startOfDay {
            return j
        } else {
            return nil
        }
    }
}
