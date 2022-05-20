//
//  Background.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/18/22.
//

import SwiftUI

struct Background: View {
    var body: some View {
        ZStack {
            Color.backgroundColor
                .ignoresSafeArea()
        }
    }
}

struct Background_Previews: PreviewProvider {
    static var previews: some View {
        Background()
    }
}
