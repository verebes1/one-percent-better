//
//  AnimatedBell.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/28/22.
//

import SwiftUI

struct AnimatedBellWrapper: View {
   
   @State private var x = 0.0
   
   @State private var isAnimating = false
   
   @Binding var animateBell: Bool
   
   func animate() {
      if !isAnimating {
         withAnimation(.linear(duration: 1.0)) {
            x = 10
            isAnimating = true
         }
      }
   }
   
   var body: some View {
      ZStack {
         AnimatedBell(x: x, isAnimating: $isAnimating, animateBell: $animateBell)
            .onTapGesture {
               animate()
            }
            .onChange(of: isAnimating) { newValue in
               if !newValue {
                  x = 0.0
               }
            }
            .onChange(of: animateBell) { newValue in
               animate()
            }
      }
   }
}

struct AnimatedBell: View, Animatable {
   
   var x: Double
   
   @Binding var isAnimating: Bool
   @Binding var animateBell: Bool
   
   var animatableData: Double {
      get { x }
      set { x = newValue }
   }
   
   var rotationAngle: Angle {
      let one = sin(3 * x)
      let two = 50 * exp(-0.5 * x)
      let three = one * two
      return Angle.init(degrees: three)
   }
   
   var offset: Double {
      let x2 = x - 0.1
      if x2 < 0 {
         return 0
      }
      let one = sin(2.6 * x2)
      let two = 38 * exp(-0.4 * x2)
      let three = one * two
      return three
   }
   
   var body: some View {
      ZStack {
         Image("custom.bell.top.fill")
            .fitToFrame()
            .rotationEffect(rotationAngle)
         
         Image("custom.bell.bottom.fill")
            .fitToFrame()
            .offset(x: offset)
            .rotationEffect(rotationAngle)
      }
      .contentShape(Rectangle())
      .onChange(of: x) { newValue in
         if newValue == 10.0 {
            isAnimating = false
         }
      }
   }
}

struct AnimatedBell_Previews: PreviewProvider {
   static var previews: some View {
      AnimatedBellWrapper(animateBell: .constant(false))
         .frame(width: 100, height: 100)
   }
}

