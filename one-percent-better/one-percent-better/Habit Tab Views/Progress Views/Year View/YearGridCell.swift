//
//  YearGridCell.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 4/26/23.
//

import SwiftUI

struct YearGridCell: View {
   
   @Environment(\.colorScheme) var scheme
   
   var color: Color
   var size: Double
   var percent: Double
   
   var cornerRadius: Double {
      return size / 7
   }
   
   var notFilledColor: Color {
      scheme == .light ? .systemGray5 : .systemGray3
   }
   
   var backgroundColor: Color {
      scheme == .light ? .cardColor : .cardColorOpposite
   }
   
   func borderColor() -> Color {
      if percent == 0 {
         return notFilledColor
      } else if scheme == .light {
         return color.colorWithOpacity(percent, onBackground: .cardColor).darkenColor()
      } else {
         // Maybe make this lighten the color?
         return color.colorWithOpacity(percent, onBackground: .cardColorOpposite2).darkenColor()
      }
   }
   
   var body: some View {
      RoundedRectangle(cornerRadius: cornerRadius)
         .fill(percent == 0 ? notFilledColor : color.opacity(percent))
         .aspectRatio(1, contentMode: .fit)
         .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
               .strokeBorder(borderColor(),
                             lineWidth: cornerRadius / 1.4)
         )
         .frame(width: size, height: size)
   }
}

struct YearViewSquare_Previews: PreviewProvider {
   static var previews: some View {
      VStack {
         HStack(spacing: 20) {
            YearGridCell(color: .green,
                           size: 150,
                           percent: 1)
            
            YearGridCell(color: .green,
                           size: 100,
                           percent: 1)
            
            YearGridCell(color: .green,
                           size: 50,
                           percent: 1)
         }
         
         HStack(spacing: 20) {
            YearGridCell(color: .blue,
                           size: 150,
                           percent: 1)
            
            YearGridCell(color: .blue,
                           size: 100,
                           percent: 1)
            
            YearGridCell(color: .blue,
                           size: 50,
                           percent: 1)
         }
         
         HStack(spacing: 20) {
            YearGridCell(color: .blue,
                           size: 50,
                           percent: 0)
            
            YearGridCell(color: .blue,
                           size: 50,
                           percent: 0.5)
            
            YearGridCell(color: .blue,
                           size: 50,
                           percent: 1)
         }
         
         HStack(spacing: 20) {
            YearGridCell(color: .green,
                           size: 50,
                           percent: 0)
            
            YearGridCell(color: .green,
                           size: 50,
                           percent: 0.33)
            
            YearGridCell(color: .green,
                           size: 50,
                           percent: 0.66)
            
            YearGridCell(color: .green,
                           size: 50,
                           percent: 1)
         }
      }
   }
}
