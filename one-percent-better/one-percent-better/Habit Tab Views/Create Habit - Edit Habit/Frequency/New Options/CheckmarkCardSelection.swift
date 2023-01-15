//
//  CheckmarkCardSelection.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 1/1/23.
//

import SwiftUI

struct CheckmarkCardSelection: View {
   
   @Environment(\.colorScheme) var scheme
   
   var body: some View {
      VStack(spacing: 20) {
         HStack {
            
            Button {
               // action
            } label: {
               Image(systemName: "checkmark.circle.fill")
                  .resizable()
                  .aspectRatio(1, contentMode: .fit)
                  .frame(height: 23)
                  .foregroundColor(Style.accentColor)
            }
            .padding(.leading, 20)

            CardView {
               EveryDaily2()
            }
            .overlay {
               ZStack {
                     RoundedRectangle(cornerRadius: 10)
                        .stroke(scheme == .light ? Style.accentColor : Style.accentColor2, lineWidth: 2)
                        .padding(.horizontal, 10)
               }
            }
         }
         
         HStack {
            
            Button {
               // action
            } label: {
               Image(systemName: "circle")
                  .resizable()
                  .aspectRatio(1, contentMode: .fit)
                  .frame(height: 23)
                  .foregroundColor(Style.accentColor)
            }
            .padding(.leading, 20)

            CardView(shadow: false, color: .backgroundColor) {
               XTimesPerWeekBeginningEveryY(color: Style.accentColor)
            }
            .overlay {
               ZStack {
                  RoundedRectangle(cornerRadius: 10)
                     .stroke(scheme == .light ? Style.accentColor : Style.accentColor2, lineWidth: 1)
                     .padding(.horizontal, 10)
               }
            }
         }
      }
   }
}

struct CheckmarkCardSelection_Previews: PreviewProvider {
   static var previews: some View {
      Background {
         CheckmarkCardSelection()
      }
   }
}
