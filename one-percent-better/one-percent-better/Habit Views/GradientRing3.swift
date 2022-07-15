//
//  GradientRing3.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 7/13/22.
//

import SwiftUI

struct GradientRing3: View {
    
    var size: CGFloat = 250
    var lineWidth: CGFloat {
        size/5
    }

    /// The percent completion of the circle
    /// Last point before the two ends touch: 0.935
    var percent: Double = 1.0
    var realPercent: Double {
        1 - percent
    }
    
    var startColor = Color( #colorLiteral(red: 0.2066814005, green: 0.7795598507, blue: 0.349144876, alpha: 1) )
    var endColor = Color( #colorLiteral(red: 0.4735379219, green: 1, blue: 0.5945096612, alpha: 1) )
    
    let shadowOpacity: Double = 0.5
    
    var shadowRadius: CGFloat {
        lineWidth/3
    }
    
    
    
    var body: some View {
        ZStack {
            GrayCircle(diameter: size, lineWidth: lineWidth)
            
            let startAngle: CGFloat = 22
            let endAngle: CGFloat = 2
            
            let angularGradient = AngularGradient(gradient: Gradient(colors: [endColor, startColor]),
                                                  center: .center,
                                                  startAngle: .init(degrees: startAngle),
                                                  endAngle: .init(degrees: 360 + endAngle))
            
            Circle()
                .trim(from: realPercent, to: 1)
                .stroke(angularGradient, style: .init(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .rotation3DEffect(.init(degrees: 180), axis: (x: 1, y: 0, z: 0))
                .rotation3DEffect(.init(degrees: -90), axis: (x: 0, y: 0, z: 1))
                .shadow(color: .black.opacity(shadowOpacity), radius: shadowRadius)
                .frame(width: size, height: size)
        }
    }
}

struct GradientRing3_Previews: PreviewProvider {
    static var previews: some View {
        GradientRing3()
    }
}
