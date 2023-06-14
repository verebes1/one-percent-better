//
//  BorderedRectangle.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 4/26/23.
//

import SwiftUI

struct BorderedRectangle: View {
   
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
               .strokeBorder(percent == 0 ? notFilledColor : color.colorWithOpacity(percent, onBackground: backgroundColor).darkenColor(), lineWidth: cornerRadius / 2)
               .brightness(0)
         )
         .frame(width: size, height: size)
         .border(.red)
   }
}

struct BorderedRectangle_Previews: PreviewProvider {
   static var previews: some View {
      VStack {
         HStack(spacing: 20) {
            BorderedRectangle(color: .green,
                           size: 150,
                           percent: 1)
            
            BorderedRectangle(color: .green,
                           size: 100,
                           percent: 1)
            
            BorderedRectangle(color: .green,
                           size: 50,
                           percent: 1)
         }
         
         HStack(spacing: 20) {
            BorderedRectangle(color: .blue,
                           size: 150,
                           percent: 1)
            
            BorderedRectangle(color: .blue,
                           size: 100,
                           percent: 1)
            
            BorderedRectangle(color: .blue,
                           size: 50,
                           percent: 1)
         }
         
         HStack(spacing: 20) {
            BorderedRectangle(color: .blue,
                           size: 50,
                           percent: 0)
            
            BorderedRectangle(color: .blue,
                           size: 50,
                           percent: 0.5)
            
            BorderedRectangle(color: .blue,
                           size: 50,
                           percent: 1)
         }
         
         HStack(spacing: 20) {
            BorderedRectangle(color: .green,
                           size: 50,
                           percent: 0)
            
            BorderedRectangle(color: .green,
                           size: 50,
                           percent: 0.33)
            
            BorderedRectangle(color: .green,
                           size: 50,
                           percent: 0.66)
            
            BorderedRectangle(color: .green,
                           size: 50,
                           percent: 1)
         }
      }
   }
}
