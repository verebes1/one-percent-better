//
//  ExpandingFillButton.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 9/27/22.
//

import SwiftUI

struct ExpandingFillButton: View {
    
//    let action: () -> Void
    
    var body: some View {
        Button {
            // do nothing
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 7)
                    .foregroundColor(.systemGray5)
                Text("Press me")
            }
        }
        .frame(width: 100, height: 20)
        .buttonStyle(ExpandingButtonStyle())

    }
}

struct ExpandingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .foregroundColor(configuration.isPressed ? .systemGray2.opacity(0.9) : .clear)
            )
    }
}

struct ExpandingFillButton_Previews: PreviewProvider {
    static var previews: some View {
        ExpandingFillButton()
    }
}
