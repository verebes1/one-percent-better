//
//  Style.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 1/10/22.
//

import Foundation
import UIKit
import SwiftUI

// https://coolors.co/f94144-f3722c-f8961e-f9c74f-90be6d-43aa8b-577590


extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}

class Style {
//    static var green = UIColor(rgb: 0x90BE6D)
    static var UIKitGreen: UIColor = .systemGreen
    static var red = UIColor(rgb: 0xF94144)
    static var lightGray: UIColor = .lightGray
    
    static var accentColor: Color = .systemTeal
}
