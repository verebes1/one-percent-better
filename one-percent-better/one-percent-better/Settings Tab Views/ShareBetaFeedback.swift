//
//  ProvideFeedback.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 7/9/23.
//

import SwiftUI

struct ShareBetaFeedback: View {
    var body: some View {
        Background {
            ScrollView {
                HabitCreationHeader(systemImage: "arrowshape.turn.up.right.fill", title: "Share Feedback", subtitle: "All feedback is anonymous")
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("1. Take a screenshot anywhere in the app.")
                    
                    Spacer().frame(height: 5)
                    
                    Text("2. Tap on the screenshot and share it:")
                    
                    Image("screenshot_beta_feedback")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedCornersShape(radius: 10, corners: .allCorners))
                    
                    Spacer().frame(height: 5)
                    Text("3. In the share menu, select ") + Text("Share Beta Feedback:").bold()
                    
                    Image("share_beta_feedback")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedCornersShape(radius: 10, corners: .allCorners))
                    
                    VStack {
                        Spacer().frame(height: 10)
                        Divider()
                        Spacer().frame(height: 10)
                    }
                    
                    Text("Alternatively, you can select 1% Better in the TestFlight app, and select ") + Text("Send Beta Feedback.").bold()
                }
                .foregroundColor(.label)
                .padding(.horizontal, 20)
                
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProvideFeedback_Previews: PreviewProvider {
    static var previews: some View {
        ShareBetaFeedback()
    }
}
