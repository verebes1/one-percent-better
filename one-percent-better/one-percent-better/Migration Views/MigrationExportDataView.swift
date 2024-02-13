//
//  MigrationExportDataView.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 2/12/24.
//

import SwiftUI

struct MigrationExportDataView: View {
    
    @State private var appeared = false
    let delay = 0.15
    
    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            Spacer()
            VStack(spacing: 10) {
                Image(systemName: "square.and.arrow.up.fill")
                    .fitToFrame()
                    .frame(width: 65, height: 65)
                    .foregroundStyle(LinearGradient(colors: [Style.accentColor, Style.accentColor2], startPoint: UnitPoint(x: 0.0, y: 0.0), endPoint: UnitPoint(x: 1.5, y: 0.6)))
                    .entranceTransition($appeared)
                
                Spacer().frame(height: 10)
                
                Text("Export Data")
                    .font(.largeTitle)
                    .bold()
                    .entranceTransition($appeared, delay: delay)
                
                Text("Choose a location on your device to save your data.")
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
            VStack {
                Button {
                    appeared.toggle()
                } label: {
                    Text("Export")
                }
                .buttonStyle(.wideAccent)
                
                Button {
                    // skip
                } label: {
                    Text("Skip").bold()
                }
            }
        }
        .backgroundColor()
    }
}

#Preview {
    MigrationExportDataView()
}
