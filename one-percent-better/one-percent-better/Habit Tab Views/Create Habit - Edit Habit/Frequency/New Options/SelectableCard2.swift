//
//  SelectableCard2.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 1/9/23.
//

import SwiftUI

struct SelectableCard2<Content>: View where Content: View {
   
   @Environment(\.colorScheme) var scheme
   
   var isSelected: Bool
   
   let content: () -> Content
   
   var onSelection: () -> Void = {}
   
   @State private var scale = 1.0
   
   var checkmarkImageName: String {
      isSelected ? "checkmark.circle.fill" : "circle"
   }
   
   var body: some View {
      HStack {
         Image(systemName: checkmarkImageName)
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .frame(height: 23)
            .foregroundColor(Style.accentColor)
            .padding(.leading, 20)
         
         CardView {
            content()
         }
         .overlay {
            if isSelected {
               ZStack {
                  RoundedRectangle(cornerRadius: 10)
                     .stroke(Style.accentColor, lineWidth: 2)
                     .padding(.horizontal, 10)
               }
            }
         }
         .scaleEffect(scale)
      }
      .gesture(
         DragGesture(minimumDistance: 0)
            .onChanged({ _ in
               if !isSelected {
                  withAnimation(.easeInOut(duration: 0.15)) {
                     scale = 0.95
                  }
               }
            })
            .onEnded({ _ in
               withAnimation(.easeInOut(duration: 0.15)) {
                  scale = 1
                  onSelection()
               }
            })
      )
//      .border(.black)
//      .fontWeight(isSelected ? .medium : .regular)
   }
}

struct SelectableCard2Wrapper<Content>: View where Content: View {
   
   @Binding var selection: HabitFrequencyTest
   let type: HabitFrequencyTest
   let content: () -> Content
   
   var body: some View {
      SelectableCard2(isSelected: selection == type) {
         content()
      } onSelection: {
         selection = type
      }
      .contentShape(Rectangle())
   }
}

struct SelectableCard2_Previewer: View {
   
   @State private var selection: HabitFrequencyTest = .timesPerDay(2)
   
   var body: some View {
      Background {
         VStack {
            SelectableCard2Wrapper(selection: $selection, type: .timesPerDay(2)) {
               EveryDaily2()
            }
            
            SelectableCard2Wrapper(selection: $selection, type: .daysInTheWeek([1,2,3])) {
               XTimesPerWeekBeginningEveryY()
            }
         }
      }
   }
}

struct SelectableCard2_Previews: PreviewProvider {
   static var previews: some View {
      SelectableCard2_Previewer()
   }
}
