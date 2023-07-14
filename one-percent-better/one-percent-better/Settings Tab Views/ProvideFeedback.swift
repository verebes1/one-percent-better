//
//  ProvideFeedback.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 7/9/23.
//

import SwiftUI

struct ProvideFeedback: View {
   var body: some View {
      Background {
         VStack {
            HabitCreationHeader(systemImage: "camera.shutter.button.fill", title: "Share Feedback")
            
            VStack(alignment: .leading, spacing: 10) {
               Text("1. Take a screenshot to send feedback directly to the developer.")

               Text("2. A popup will appear, then select the Share button in the upper right hand corner.")
               
               Text("3. Then select: \"Share Beta Feedback\".")
            }
            .padding(.horizontal, 20)
            
            Spacer()
         }
      }
   }
}

struct ProvideFeedback_Previews: PreviewProvider {
   static var previews: some View {
      ProvideFeedback()
   }
}
