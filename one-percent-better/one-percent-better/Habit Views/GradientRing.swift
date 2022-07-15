//
//  GradientRing.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 7/5/22.
//

import SwiftUI

struct GradientRing: View {

    var startColor = Color( #colorLiteral(red: 0, green: 0.7286170125, blue: 0.879304111, alpha: 1) )
    var endColor = Color( #colorLiteral(red: 0.009636783041, green: 0.9831244349, blue: 0.8203613162, alpha: 1) )
    
//    var startColor = Color( #colorLiteral(red: 0.2066814005, green: 0.7795598507, blue: 0.349144876, alpha: 1) )
//    var endColor = Color( #colorLiteral(red: 0.4735379219, green: 1, blue: 0.5945096612, alpha: 1) )

   
    /// The percent completion of the circle
    /// Last point before the two ends touch: 0.935
    @State var percent: Double = 0.7
    
    /// The cutoff percent for the new overlapping ring to start
    let cutoffPercent: Double = 0.935
    
    /// The percent at which to stop progressing the circle and start rotating
    /// the circle to make it appear as if it's progressing
    let startRotation = 1.5
    
    /// Percent completion, but it cuts off at the start rotation percent
    var percentWithRotationCutoff: Double {
        percent < startRotation ? percent : startRotation
    }
    
    /// The diameter of the circle
    var size: CGFloat = 250
    
    
    /// The line width of the circle
    var lineWidth: CGFloat {
        size/5
    }
    
    let pi = 3.14159265359
    
    let shadowOpacity: Double = 0.2
    
    var shadowRadius: CGFloat {
        lineWidth/1.5
    }
    
    @State private var rotation: CGFloat = 0.0
    
    var body: some View {
        VStack {
        
//            Slider(value: $percent, in: 0 ... 3)
//                .padding()
            
            let rotationDegrees = percent < startRotation ? 0 : 360 * (percent - startRotation)
            
            // Circle
            ZStack {
                
                GrayCircle(diameter: size, lineWidth: lineWidth)
                
                let startAngle: CGFloat = 22
                let endAngle: CGFloat = 2
                let angularGradient = AngularGradient(gradient: Gradient(colors: [endColor, startColor]),
                                                      center: .center,
                                                      startAngle: .init(degrees: startAngle),
                                                      endAngle: .init(degrees: 360 + endAngle))
                
                // Start circle
                if percent > 0 {
                    ZStack {
                        ZStack {
                            Circle()
                                .trim(from: 0, to: 0.0000000001)
                                .stroke(startColor, style: .init(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                                .rotation3DEffect(.init(degrees: 180), axis: (x: 1, y: 0, z: 0))
                                .rotation3DEffect(.init(degrees: -90), axis: (x: 0, y: 0, z: 1))
                                .shadow(color: percent > cutoffPercent ? .black.opacity(shadowOpacity) : .black.opacity(0), radius: shadowRadius)
                            .frame(width: size, height: size)
                        }
                        .frame(width: size + lineWidth, height: size + lineWidth)
                        .reverseMask {
                            RingCutout(from: 0, to: 0.1, clockwise: true)
                        }
                        .clipShape(Circle())
                    }
                    .reverseMask {
                        Circle()
                            .frame(width: size - lineWidth, height: size - lineWidth)
                    }
                }

                // Main Loop circle
                ZStack {
                    ZStack {
                        Circle()
                            .trim(from: 1 - percentWithRotationCutoff, to: 1)
                            .stroke(angularGradient, style: .init(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                            .rotation3DEffect(.init(degrees: 180), axis: (x: 1, y: 0, z: 0))
                            .rotation3DEffect(.init(degrees: -90), axis: (x: 0, y: 0, z: 1))
                            .shadow(color: .black.opacity(shadowOpacity), radius: shadowRadius)
                            .frame(width: size, height: size)
                    }
                    .frame(width: size + lineWidth, height: size + lineWidth)
                    .reverseMask {
                        if percent > cutoffPercent {
                            RingCutout(from: 0, to: cutoffPercent/* + 0.01*/, clockwise: false)
                        }
                    }
                    .clipShape(Circle())
                }
                .reverseMask {
                    Circle()
                        .frame(width: size - lineWidth, height: size - lineWidth)
                }
                
                
                // Overlapping circle
                if percent > cutoffPercent {
                    ZStack {
                        ZStack {
                            let angleOffset: CGFloat = 360 - 360 * cutoffPercent
                            let continueAngle: CGFloat = percentWithRotationCutoff - cutoffPercent
                            Circle()
                                .trim(from: 0, to: continueAngle)
                                .stroke(endColor, style: .init(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                                .rotation3DEffect(.init(degrees: -90 - angleOffset), axis: (x: 0, y: 0, z: 1))
                                .shadow(color: .black.opacity(shadowOpacity), radius: shadowRadius)
                                .frame(width: size, height: size)
                        }
                        .frame(width: size + lineWidth, height: size + lineWidth)
                        .reverseMask {
                            RingCutout(from: cutoffPercent, to: cutoffPercent - 0.1, clockwise: false)
                        }
                        .clipShape(Circle())
                    }
                    .reverseMask {
                        Circle()
                            .frame(width: size - lineWidth, height: size - lineWidth)
                    }
                }
            }
            .rotationEffect(Angle(degrees: rotationDegrees))
            
        }
    }
}

struct GradientRing_Previews: PreviewProvider {
    static var previews: some View {
        GradientRing()
    }
}

struct GrayCircle: View {

    let diameter: CGFloat
    let lineWidth: CGFloat
    
    var body: some View {
        Circle()
            .trim(from: 0, to: 1)
            .stroke(Color.gray.opacity(0.15), style: .init(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
            .rotation3DEffect(.init(degrees: 180), axis: (x: 1, y: 0, z: 0))
            .rotation3DEffect(.init(degrees: -90), axis: (x: 0, y: 0, z: 1))
            .frame(width: diameter, height: diameter)
    }
}
