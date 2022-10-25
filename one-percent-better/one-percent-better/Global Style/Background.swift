//
//  Background.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/18/22.
//

import SwiftUI

struct Background<Content>: View where Content: View {
   
   var color = Color.backgroundColor
   
   let content: () -> Content
   
   var body: some View {
      ZStack {
         color.ignoresSafeArea()
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
