//
//  SequentialTransitionView.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 2/12/24.
//

import SwiftUI

struct EntranceTransition: ViewModifier {
    @Binding var show: Bool
    let delay: Double
    
    func body(content: Content) -> some View {
        VStack {
            if show {
                content
                    .transition(
                        .opacity.combined(with: .move(edge: .bottom))
                    )
            }
        }
        .animation(.spring.delay(delay), value: show)
    }
}

extension View {
    func entranceTransition(_ show: Binding<Bool>, delay: Double = 0) -> some View {
        modifier(EntranceTransition(show: show, delay: delay))
    }
}

struct EntranceTransitionViewPreviewer: View {
    @State private var appeared = false
    var body: some View {
        ZStack {
            VStack {
                Text("Type 1")
                    .entranceTransition($appeared)
                Text("Type 2")
                    .entranceTransition($appeared, delay: 0.5)
                Text("Type 3")
                    .entranceTransition($appeared, delay: 1)
            }
            
            VStack {
                Spacer()
                Button("Toggle") {
                    appeared.toggle()
                }
            }
        }
    }
}

#Preview {
    EntranceTransitionViewPreviewer()
}
