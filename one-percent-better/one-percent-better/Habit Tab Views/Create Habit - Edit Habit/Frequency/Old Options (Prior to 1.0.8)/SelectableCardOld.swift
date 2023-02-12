//
//  SelectableCardOld.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 8/14/22.
//

import SwiftUI

struct SelectableCardOld<Content>: View where Content: View {
   
   @Environment(\.colorScheme) var scheme
   
   @Binding var selection: HabitFrequency
   let type: HabitFrequency
   let content: () -> Content
   var onSelection: () -> Void = {}
   
   var body: some View {
      CardView(padding: 20) {
         content()
      }
      .simultaneousGesture(
         TapGesture()
            .onEnded {
               onSelection()
            }
      )
      .overlay(content: {
         ZStack {
            if selection.equalType(to: type) {
               RoundedRectangle(cornerRadius: 10)
                  .stroke(scheme == .light ? Style.accentColor : Style.accentColor2, lineWidth: 2)
                  .padding(.horizontal, 20)
            }
            
            VStack {
               HStack {
                  Spacer()
                  CheckmarkToggleButton(state: selection.equalType(to: type))
                     .padding(.horizontal, 22)
                     .padding(.vertical, 7)
               }
               Spacer()
            }
         }
      })
   }
}

struct SelectableCardPreviewer: View {
   
   @State private var selection: HabitFrequency = .timesPerDay(1)
   
   var body: some View {
      Background {
         VStack {
            SelectableCardOld(selection: $selection, type: .timesPerDay(1), content: {
               VStack {
                  Text("Hello World")
                  Text("Hello World")
                  Text("Hello World")
                  Text("Hello World")
               }
            }) {
               selection = .timesPerDay(1)
            }
            
            SelectableCardOld(selection: $selection, type: .daysInTheWeek([2,4]), content: {
               VStack {
                  Text("What's good baby")
                  Text("What's good baby")
                  Text("What's good baby")
                  Text("What's good baby")
               }
            }) {
               selection = .daysInTheWeek([2,4])
            }
         }
      }
   }
}

struct SelectableCard_Previews: PreviewProvider {
   static var previews: some View {
      SelectableCardPreviewer()
   }
}


struct CheckmarkToggleButton: View {
   
   var state: Bool = true
   var size: CGFloat = 18
   
   var body: some View {
      Image(systemName: state ? "checkmark.circle.fill" : "circle")
         .resizable()
         .aspectRatio(contentMode: .fit)
         .frame(width: size, height: size)
         .foregroundColor(state ? Style.accentColor : .systemGray)
   }
}
