//
//  CapsuleTextStyle.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 1/23/23.
//

import SwiftUI

struct CapsuleLabel: View {
   
   @Environment(\.colorScheme) var scheme
   
   var text: String
   var systemImage: String
   var fontSize: CGFloat = 18
   var color: Color = Style.accentColor
   
   private var textColor: Color {
      scheme == .light ? .white : .black
   }
   
   var body: some View {
      Label(text, systemImage: systemImage)
         .font(.system(size: fontSize))
         .fontWeight(.medium)
         .padding(.vertical, fontSize/3.5)
         .padding(.horizontal, fontSize * 0.7)
         .foregroundColor(textColor)
         .fontWeight(.medium)
         .background(color)
         .clipShape(Capsule())
   }
}

struct CapsuleTextStyle_Previews: PreviewProvider {
   static var previews: some View {
      CapsuleLabel(text: "New Tracker", systemImage: "plus")
   }
}
