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
   static let cardColorOpposite2 = Color("CardColorOpposite2")
   static let cardColorLighter = Color("CardColorLighter")
   static let grayButton = Color("GrayButton")
   
   static let calendarGray = Color(#colorLiteral(red: 0.7812705636, green: 0.7763053775, blue: 0.7978962064, alpha: 1))
   static let calendarGrayNotInMonth = Color(#colorLiteral(red: 0.9568627477, green: 0.9568627477, blue: 0.9568627477, alpha: 1))
   static let calendarNumberColor = Color(UIColor.dynamicColor(light: UIColor.label, dark: UIColor.secondaryLabel))
   
   static var random: Color {
      return Color(
         red: .random(in: 0...1),
         green: .random(in: 0...1),
         blue: .random(in: 0...1)
      )
   }
   
   // MARK: - Text Colors
   static let lightText = Color(UIColor.lightText)
   static let darkText = Color(UIColor.darkText)
   static let placeholderText = Color(UIColor.placeholderText)
   
   // MARK: - Label Colors
   static let label = Color(UIColor.label)
   static let secondaryLabel = Color(UIColor.secondaryLabel)
   static let tertiaryLabel = Color(UIColor.tertiaryLabel)
   static let quaternaryLabel = Color(UIColor.quaternaryLabel)
   
   static func labelOpposite(scheme: ColorScheme) -> Color {
      switch scheme {
      case .light:
         return Color.white
      case .dark:
         return Color.black
      default:
         return Color.darkText
      }
   }
   
   // MARK: - Background Colors
   static let systemBackground = Color(UIColor.systemBackground)
   static let secondarySystemBackground = Color(UIColor.secondarySystemBackground)
   static let tertiarySystemBackground = Color(UIColor.tertiarySystemBackground)
   
   // MARK: - Fill Colors
   static let systemFill = Color(UIColor.systemFill)
   static let secondarySystemFill = Color(UIColor.secondarySystemFill)
   static let tertiarySystemFill = Color(UIColor.tertiarySystemFill)
   static let quaternarySystemFill = Color(UIColor.quaternarySystemFill)
   
   // MARK: - Grouped Background Colors
   static let systemGroupedBackground = Color(UIColor.systemGroupedBackground)
   static let secondarySystemGroupedBackground = Color(UIColor.secondarySystemGroupedBackground)
   static let tertiarySystemGroupedBackground = Color(UIColor.tertiarySystemGroupedBackground)
   
   // MARK: - Gray Colors
   static let systemGray = Color(UIColor.systemGray)
   static let systemGray2 = Color(UIColor.systemGray2)
   static let systemGray3 = Color(UIColor.systemGray3)
   static let systemGray4 = Color(UIColor.systemGray4)
   static let systemGray5 = Color(UIColor.systemGray5)
   static let systemGray6 = Color(UIColor.systemGray6)
   
   // MARK: - Other Colors
   static let separator = Color(UIColor.separator)
   static let opaqueSeparator = Color(UIColor.opaqueSeparator)
   static let link = Color(UIColor.link)
   
   // MARK: System Colors
   static let systemBlue = Color(UIColor.systemBlue)
   static let systemPurple = Color(UIColor.systemPurple)
   static let systemGreen = Color(UIColor.systemGreen)
   static let systemYellow = Color(UIColor.systemYellow)
   static let systemOrange = Color(UIColor.systemOrange)
   static let systemPink = Color(UIColor.systemPink)
   static let systemRed = Color(UIColor.systemRed)
   static let systemTeal = Color(UIColor.systemTeal)
   static let systemIndigo = Color(UIColor.systemIndigo)
   
   func darkenColor() -> Color {
      return Color(UIColor(self).darkenColor())
   }
   
   func lightenColor() -> Color {
      return Color(UIColor(self).lightenColor())
   }
   
   func colorWithOpacity(_ opacity: CGFloat, onBackground: Color) -> Color {
      return Color(UIColor(self).colorWithOpacity(onBackgroundColor: UIColor(onBackground), opacity: opacity))
   }
}

extension UIColor {
   static func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
      guard #available(iOS 13.0, *) else { return light }
      return UIColor { $0.userInterfaceStyle == .dark ? dark : light }
   }
   
   func darkenColor() -> UIColor {
      var hue: CGFloat = 0
      var saturation: CGFloat = 0
      var brightness: CGFloat = 0
      var alpha: CGFloat = 0
      
      if self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
         let hueAdjustment: CGFloat = 5 // 5
         let saturationAdjustment: CGFloat = 13 // 9
         let brightnessAdjustment: CGFloat = -12 // -5
         
         print("~~~ h: \(hue), s: \(saturation), b: \(brightness), alpha: \(alpha)")
         
         hue = (hue * 360 + hueAdjustment) / 360
         saturation = max(0, saturation * 100 + saturationAdjustment) / 100
         brightness = max(0, brightness * 100 + brightnessAdjustment) / 100
         
         print("--- h: \(hue), s: \(saturation), b: \(brightness), alpha: \(alpha)")
         
         return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
      }
      return self
   }
   
   func lightenColor() -> UIColor {
      var hue: CGFloat = 0
      var saturation: CGFloat = 0
      var brightness: CGFloat = 0
      var alpha: CGFloat = 0
      
      if self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
         let hueAdjustment: CGFloat = 5 // 5
         let saturationAdjustment: CGFloat = 9 // 9
         let brightnessAdjustment: CGFloat = 13 // -5
         
         print("~~~ h: \(hue), s: \(saturation), b: \(brightness), alpha: \(alpha)")
         
         hue = (hue * 360 + hueAdjustment) / 360
         saturation = max(0, saturation * 100 + saturationAdjustment) / 100
         brightness = max(0, brightness * 100 + brightnessAdjustment) / 100
         
         print("--- h: \(hue), s: \(saturation), b: \(brightness), alpha: \(alpha)")
         
         return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
      }
      return self
   }
   
   func colorWithOpacity(onBackgroundColor backgroundColor: UIColor, opacity: CGFloat) -> UIColor {
      
      print("backgroundColor: \(backgroundColor.description), opacity: \(opacity)")
      
      // Get the RGB values of the original color
      var red: CGFloat = 0
      var green: CGFloat = 0
      var blue: CGFloat = 0
      var alpha: CGFloat = 0
      self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
      
      // Get the RGB values of the background color
      var bgRed: CGFloat = 0
      var bgGreen: CGFloat = 0
      var bgBlue: CGFloat = 0
      var bgAlpha: CGFloat = 0
      backgroundColor.getRed(&bgRed, green: &bgGreen, blue: &bgBlue, alpha: &bgAlpha)
      
      // Blend the original color with the background color
      let blendedRed = red * opacity + bgRed * (1 - opacity)
      let blendedGreen = green * opacity + bgGreen * (1 - opacity)
      let blendedBlue = blue * opacity + bgBlue * (1 - opacity)
      
      // Create and return the blended color
      return UIColor(red: blendedRed, green: blendedGreen, blue: blendedBlue, alpha: 1)
   }
}

extension Color {
   static func dynamicColor(light: Color, dark: Color) -> Color {
      guard #available(iOS 13.0, *) else { return light }
      return Color (UIColor { $0.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light) })
   }
}
