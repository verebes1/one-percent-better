//
//  Color.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/17/22.
//

import Foundation
import SwiftUI

extension Color {
    static let backgroundColor = Color("BackgroundColor")
    static let cardColor = Color("CardColor")
    static let cardColorOpposite = Color("CardColorOpposite")
    
    static let calendarGray = Color(#colorLiteral(red: 0.7812705636, green: 0.7763053775, blue: 0.7978962064, alpha: 1))
    static let calendarGrayNotInMonth = Color(#colorLiteral(red: 0.9568627477, green: 0.9568627477, blue: 0.9568627477, alpha: 1))
    
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
    
}
