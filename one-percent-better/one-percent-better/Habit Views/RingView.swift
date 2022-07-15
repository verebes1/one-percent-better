//
//  RingView.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 4/25/22.
//

import SwiftUI

struct RingView: View {
    var percent: Double
    var color: Color = .green
    var size: CGFloat = 100
    var withText: Bool = false
    var startColor = Color( #colorLiteral(red: 0, green: 0.7286170125, blue: 0.879304111, alpha: 1) )
    var endColor = Color( #colorLiteral(red: 0.009636783041, green: 0.9831244349, blue: 0.8203613162, alpha: 1) )
    
    var lineWidth: CGFloat {
        size / 5
    }
    
    @State var completed: Bool = false
    
    var body: some View {
        VStack(spacing: 5) {
            GradientRing(startColor: startColor, endColor: endColor, percent: percent, size: size)
                .animation(.easeInOut, value: percent)
            
            if withText {
                if let intPercent = Int(round(100 * percent)) {
                    Text("\(intPercent)%")
                        .font(.system(size: size/3))
                        .fontWeight(.bold)
                        .foregroundColor(startColor)
                }
            }
        }
        .contentShape(Rectangle())
    }
}

struct RingView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            RingView(percent: 0.435)
                .border(Color.black, width: 1)
            
            RingView(percent: 0.435,
                     withText: true)
            
            RingView(percent: 0.435,
                     size: 28)
            .border(Color.black, width: 1)
        }
    }
}
