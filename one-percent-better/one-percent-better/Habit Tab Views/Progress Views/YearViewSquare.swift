//
//  YearViewSquare.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 4/26/23.
//

import SwiftUI

struct YearViewSquare: View {
   
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
   
   var body: some View {
      RoundedRectangle(cornerRadius: cornerRadius)
         .fill(percent == 0 ? notFilledColor : color.opacity(percent))
         .aspectRatio(1, contentMode: .fit)
         .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
               .stroke(percent == 0 ? notFilledColor : color.colorWithOpacity(percent, onBackground: backgroundColor).darkenColor(), lineWidth: cornerRadius / 2)
               .brightness(0)
         )
         .frame(width: size, height: size)
   }
}

struct YearViewSquare_Previews: PreviewProvider {
   static var previews: some View {
      VStack {
         HStack(spacing: 20) {
            YearViewSquare(color: .green,
                           size: 150,
                           percent: 1)
            
            YearViewSquare(color: .green,
                           size: 100,
                           percent: 1)
            
            YearViewSquare(color: .green,
                           size: 50,
                           percent: 1)
         }
         
         HStack(spacing: 20) {
            YearViewSquare(color: .blue,
                           size: 150,
                           percent: 1)
            
            YearViewSquare(color: .blue,
                           size: 100,
                           percent: 1)
            
            YearViewSquare(color: .blue,
                           size: 50,
                           percent: 1)
         }
         
         HStack(spacing: 20) {
            YearViewSquare(color: .blue,
                           size: 50,
                           percent: 0)
            
            YearViewSquare(color: .blue,
                           size: 50,
                           percent: 0.5)
            
            YearViewSquare(color: .blue,
                           size: 50,
                           percent: 1)
         }
         
         HStack(spacing: 20) {
            YearViewSquare(color: .green,
                           size: 50,
                           percent: 0)
            
            YearViewSquare(color: .green,
                           size: 50,
                           percent: 0.33)
            
            YearViewSquare(color: .green,
                           size: 50,
                           percent: 0.66)
            
            YearViewSquare(color: .green,
                           size: 50,
                           percent: 1)
         }
      }
   }
}
