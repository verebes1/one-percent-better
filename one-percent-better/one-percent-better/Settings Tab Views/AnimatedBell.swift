//
//  AnimatedBell.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/28/22.
//

import SwiftUI

struct AnimatedBell: View {
   
   @State private var rotationAngle = 0.0
   
    var body: some View {
       ZStack {
          Image("custom.bell.top.fill")
             .resizable()
             .aspectRatio(contentMode: .fit)
             .frame(width: 50, height: 50)
             .rotationEffect(.init(degrees: rotationAngle))
          
          Image("custom.bell.bottom.fill")
             .resizable()
             .aspectRatio(contentMode: .fit)
             .frame(width: 50, height: 50)
             .rotationEffect(.init(degrees: rotationAngle))
       }
       .onTapGesture {
          withAnimation {
             rotationAngle += 360
          }
       }
    }
}

struct AnimatedBell_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedBell()
    }
}
