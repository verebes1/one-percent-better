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
            HabitCreationHeader(systemImage: "camera.shutter.button.fill", title: "Provide Feedback")
            
            Text("Simply take a screenshot to send feedback directly to the developer.")
            
            Text("A popup will appear, then select \"Share Beta Feedback\"")
            
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
