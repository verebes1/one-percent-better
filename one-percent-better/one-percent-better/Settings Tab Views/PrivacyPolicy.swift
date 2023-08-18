//
//  PrivacyPolicy.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 8/17/23.
//

import SwiftUI

struct PrivacyPolicy: View {
    var body: some View {
        Background {
            VStack {
                HabitCreationHeader(systemImage: "lock.fill", title: "Privacy Policy", subtitle: "You own your data")
                VStack(alignment: .leading, spacing: 20) {
                    Text("A person's habits are private by nature, and I take that seriously. All data is stored locally on device with only one exception:")
                    
                    Text("If you add AI notifications to a habit, the name of that habit will be used when querying OpenAI to generate unique notifications. However, there is no personal information which can be tied back to you associated with these requests, and I can't see any information in these requests.")
                    
                    Text("Besides this, \(Text("you own your data").bold()), and no one can see it or access it, including me.")
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
            }
        }
    }
}

struct PrivacyPolicy_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPolicy()
    }
}
