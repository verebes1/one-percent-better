//
//  RingShape.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 7/6/22.
//

import SwiftUI

struct RingCutout: Shape {
    
    let from: Double
    let to: Double
    var clockwise: Bool = false
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            let r: CGFloat = (rect.maxX - rect.minX) / 2
            let startAngle = from * 360
            let endAngle = to * 360
            path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: r, startAngle: .init(degrees: -90 + startAngle), endAngle: .init(degrees: -90 + endAngle), clockwise: !clockwise)
            path.addLine(to: CGPoint(x: rect.midX, y: rect.minY + r))
        }
    }
}

struct RingShape: View {
    var color2 = Color( #colorLiteral(red: 0, green: 0.7286170125, blue: 0.879304111, alpha: 1) )
    var color = Color( #colorLiteral(red: 0.009636783041, green: 0.9831244349, blue: 0.8203613162, alpha: 1) )
    
    var body: some View {
        VStack {
            let gradient = LinearGradient(gradient: Gradient(colors: [color, color2]), startPoint: .leading, endPoint: .trailing)
            
            Text("Counter-clockwise")
            RingCutout(from: 0, to: 0.75)
                .fill(gradient)
                .frame(width: 100, height: 100)
            
            Text("Clockwise")
            RingCutout(from: 0, to: 0.25, clockwise: true)
                .fill(gradient)
                .frame(width: 100, height: 100)
        }
    }
}

struct RingShape_Previews: PreviewProvider {
    static var previews: some View {
        RingShape()
    }
}
