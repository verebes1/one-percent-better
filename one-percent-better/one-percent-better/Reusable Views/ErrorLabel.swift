//
//  ErrorLabel.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 8/28/22.
//

import SwiftUI

struct ErrorLabel: View {
    
    var message: String
    @Binding var showError: Bool
    
    var body: some View {
        if showError {
            Label(message, systemImage: "exclamationmark.triangle")
                .foregroundColor(.red)
                .animation(.easeInOut, value: showError)
        }
    }
}

struct ErrorLabel_Previews: PreviewProvider {
    static var previews: some View {
        ErrorLabel(message: "Habit name can't be empty", showError: .constant(true))
    }
}
