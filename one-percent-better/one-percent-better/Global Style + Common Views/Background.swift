//
//  Background.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/18/22.
//

import SwiftUI

struct Background<Content>: View where Content: View {
   
   
   @Environment(\.colorScheme) var scheme
   
   var color = Color.backgroundColor
   
   var topColor: Color = Color(#colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1))
   var bottomColor: Color = Color(#colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1))
   
   let content: () -> Content
   
   var body: some View {
      ZStack {
         LinearGradient(colors: [bottomColor, topColor], startPoint: .init(x: 0, y: 1), endPoint: .init(x: 0, y: 0))
                     .ignoresSafeArea()
//         color.ignoresSafeArea()
         
         content()
      }
   }
}

struct Background_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Background {
                Text("Light Mode")
            }
            .preferredColorScheme(.light)
            
            Background {
                Text("Dark Mode")
            }
            .preferredColorScheme(.dark)
        }
    }
}
