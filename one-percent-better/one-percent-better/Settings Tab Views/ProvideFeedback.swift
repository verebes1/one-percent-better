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
            HabitCreationHeader(systemImage: "arrowshape.turn.up.right.fill", title: "Share Feedback")
            
            VStack(alignment: .leading, spacing: 10) {
               Text("Take a screenshot anywhere in the app.")
               
               Spacer().frame(height: 10)
               
               Text("Tap on the screenshot and share it:")
               
               Image("screenshot_beta_feedback")
                  .resizable()
                  .aspectRatio(contentMode: .fit)
                  
               Spacer().frame(height: 10)
               Text("In the share menu, select ") + Text("Share Beta Feedback:").bold()
               
               Image("share_beta_feedback")
                  .resizable()
                  .aspectRatio(contentMode: .fit)
            }
            .foregroundColor(.label)
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
