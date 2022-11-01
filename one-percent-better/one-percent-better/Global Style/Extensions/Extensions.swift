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

// MARK: - Date

extension Date {
    func localDate() -> String {
        self.description(with: .current)
    }
    
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
    
    func monthAndDay() -> String {
        let components = self.get(.day, .month)
        return "\(components.month!)/\(components.day!)"
    }
    
    func day() -> String {
        let components = self.get(.day, .month)
        return "\(components.day!)"
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

// MARK: - Calendar

extension Calendar {
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from)
        let toDate = startOfDay(for: to)
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate)
        return numberOfDays.day! + 1
    }
}


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

extension Image {
   func fitToFrame() -> some View {
      return self
         .resizable()
         .aspectRatio(contentMode: .fit)
   }
}

extension View {
   func printType() -> some View {
      print(type(of: self))
      return self
   }
}

extension View {
   func printChanges() -> some View {
      let _ = Self._printChanges()
      return self
   }
}
