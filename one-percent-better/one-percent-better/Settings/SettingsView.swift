//
//  SettingsView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/12/22.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        Background {
            CardView {
                VStack {
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 7)
                                .foregroundColor(.red)
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.white)
                        }
                        .frame(width: 28, height: 28)
                        Text("Export Data")
                            .font(.system(size: 21))
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
