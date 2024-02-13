//
//  MigrationView.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 2/12/24.
//

import SwiftUI

struct MigrationView: View {
    
    @State private var appeared = false
    
    let delay = 0.15
    
    var body: some View {
        Background {
            VStack(alignment: .center, spacing: 30) {
                Spacer()
                VStack(spacing: 10) {
                    Image(systemName: "arrow.up.forward.app.fill")
                       .fitToFrame()
                       .frame(width: 65, height: 65)
                       .foregroundStyle(LinearGradient(colors: [Style.accentColor, Style.accentColor2], startPoint: UnitPoint(x: 0.0, y: 0.0), endPoint: UnitPoint(x: 1.5, y: 0.6)))
                       .entranceTransition($appeared)
                    
                    Spacer().frame(height: 10)
                    
                    Text("Migrate To New App")
                        .font(.largeTitle)
                        .bold()
                        .entranceTransition($appeared, delay: delay)
                    
                    Text("Ownership of this app is changing! Please follow the instructions below to transition to the updated app.")
                        .fontWeight(.regular)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .entranceTransition($appeared, delay: 2 * delay)
                }
                .padding(.horizontal, 30)
                .onAppear {
                    appeared = true
                }
                
                Spacer()
                Button {
                    appeared.toggle()
                } label: {
                    Text("Next")
                }
                .buttonStyle(.wideAccent)
            }
        }
    }
}

#Preview {
    VStack {
        MigrationView()
    }
}
