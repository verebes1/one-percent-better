//
//  DepressTest.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 1/9/23.
//

import SwiftUI

struct DepressTest: View {
   
   @State private var scale = 1.0
   
   var body: some View {
      Text("Press me!")
         .gesture(
            DragGesture(minimumDistance: 0)
               .onChanged({ _ in
                  withAnimation(.easeInOut(duration: 0.2)) {
                     scale = 0.8
                  }
               })
               .onEnded({ _ in
                  withAnimation(.easeInOut(duration: 0.2)) {
                     scale = 1
                  }
               })
         )
//         .onTapGesture {
//            withAnimation {
//               scale = 1.5
//            }
//         }
         .scaleEffect(scale)
      
      Text("value: \(scale)")
   }
}

struct DepressTest_Previews: PreviewProvider {
   static var previews: some View {
      DepressTest()
   }
}
