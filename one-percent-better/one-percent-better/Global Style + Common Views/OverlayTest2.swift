//
//  OverlayTest2.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 12/10/22.
//

import SwiftUI

struct OverlayTest2: View {
   @State private var showOverlay = false
   
   var body: some View {
      ZStack {
         // Your main content goes here...
         
         // Add a button to trigger the overlay
         Button("Show Overlay") {
            withAnimation {
               self.showOverlay.toggle()
            }
         }
         
         // Create the overlay and animate its appearance
         if showOverlay {
            OverlayView()
               .frame(width: 300, height: 200)
               .background(Color.blue)
               .cornerRadius(20)
               .transition(.move(edge: .top))
//               .transition(.move(edge: .top))
               .animation(.default)
         }
      }
   }
}

struct OverlayView: View {
   var body: some View {
      // Your overlay content goes here...
      VStack {
         Text("Test")
      }
      .overlay(
         HStack {
            Spacer()
            Button(action: {
               // Close the view when the button is tapped
            }) {
               Image(systemName: "xmark")
                  .font(.title)
                  .foregroundColor(.black)
            }
            .padding()
         }
      )
   }
}

struct OverlayTest2_Previews: PreviewProvider {
   static var previews: some View {
      OverlayTest2()
   }
}
