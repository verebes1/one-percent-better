//
//  IconTextRow.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/18/22.
//

import SwiftUI

struct IconTextRow: View {
   var title: String
   var icon: String
   var color: Color
   var body: some View {
      HStack {
         ZStack {
            let rectangleSize: CGFloat = 28
            RoundedRectangle(cornerRadius: 7)
               .foregroundColor(color)
               .frame(width: rectangleSize, height: rectangleSize)
            
            let imageSize: CGFloat = 16
            Image(systemName: icon)
               .resizable()
               .aspectRatio(contentMode: .fit)
               .frame(width: imageSize, height: imageSize)
               .foregroundColor(.white)
         }
         
         Text(title)
            .font(.body)
      }
   }
}

struct IconTextRow_Previews: PreviewProvider {
   static var previews: some View {
      List {
         IconTextRow(title: "Notifications", icon: "bell.fill", color: .blue)
         IconTextRow(title: "Wifi", icon: "wifi", color: .green)
         IconTextRow(title: "Sound", icon: "speaker.wave.3.fill", color: .red)
      }
   }
}
