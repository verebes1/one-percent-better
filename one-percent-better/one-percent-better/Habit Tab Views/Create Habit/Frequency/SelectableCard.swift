//
//  SelectableCard2.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 1/9/23.
//

import SwiftUI

struct SelectableCard<Content>: View where Content: View {
   
   @Environment(\.colorScheme) var scheme
   
   /// The condition for this card to be marked as selected
   var isSelected: Bool
   
   /// The content of the card
   let content: () -> Content
   
   /// A callback for when the card is tapped
   var onSelection: () -> Void = {}
   
   var checkmarkImageName: String {
      isSelected ? "checkmark.circle.fill" : "circle"
   }
   
   let cornerRadius: CGFloat = 17
   
   var body: some View {
      CardView {
         content()
      }
      .contentShape(Rectangle())
      .overlay {
         ZStack {
            if isSelected {
               RoundedRectangle(cornerRadius: cornerRadius)
                  .stroke(Style.accentColor, lineWidth: 2.0)
                  .padding(.horizontal, 10)
            }
               
            VStack {
               HStack {
                  Spacer()
                  CheckmarkToggleButton(state: isSelected)
                     .padding(.trailing, 10)
                     .padding(10)
               }
               Spacer()
            }
         }
      }
      .simultaneousGesture(
         TapGesture()
            .onEnded { _ in
               onSelection()
            }
      )
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

struct SelectableCard_Previewer: View {
   
   @State private var selection = 0
   
   var body: some View {
      Background {
         VStack {
            ForEach(0 ..< 4) { i in
               SelectableCard(isSelected: selection == i) {
                  Text(String(describing: i))
                     .padding(.vertical, 10)
               } onSelection: {
                  selection = i
               }
            }
         }
      }
   }
}

struct SelectableCard_Previews: PreviewProvider {
   static var previews: some View {
      SelectableCard_Previewer()
   }
}
