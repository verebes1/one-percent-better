//
//  GradientRing.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 7/5/22.
//

import SwiftUI

class GradientRingViewModel: ObservableObject {
    
    @Published var percent: Double
    
    init(percent: Double) {
        self.percent = percent
    }
}

struct GradientRing: View {

    @ObservedObject var vm: GradientRingViewModel
    
    /// The percent completion of the circle
    /// Last point before the two ends touch: 0.935
    @State private var percent: Double
    
    /// The cutoff percent for the new overlapping ring to start
    let cutoffPercent: Double = 0.935
    
    /// The percent at which to stop progressing the circle and start rotating
    /// the circle to make it appear as if it's progressing
    let startRotation = 1.5
    
    /// Percent completion, but it cuts off at the start rotation percent
    var percentWithRotationCutoff: Double {
        percent < startRotation ? percent : startRotation
    }
    
    var continueAngle: CGFloat {
        let continueAngle = percentWithRotationCutoff - cutoffPercent
        let result = continueAngle > 0 ? continueAngle : 0
        return result
    }
    
    /// The color at the start of the gradient
    var startColor = Color(#colorLiteral(red: 0, green: 0.7286170125, blue: 0.879304111, alpha: 1))
    
    /// The color at the end of the gradient
    var endColor = Color(#colorLiteral(red: 0.009636783041, green: 0.9831244349, blue: 0.8203613162, alpha: 1))
    
    /// The diameter of the circle
    var size: CGFloat = 250
    
    
    /// The line width of the circle
    var lineWidth: CGFloat {
        size/5
    }
    
    let pi = 3.14159265359
    
    let shadowOpacity: Double = 0.15
    
    var shadowRadius: CGFloat {
        lineWidth/1.5
    }
    
    @State private var rotation: CGFloat = 0.0
    
    @State private var animating = false
    
    init(vm: GradientRingViewModel, startColor: Color = Color(#colorLiteral(red: 0, green: 0.7286170125, blue: 0.879304111, alpha: 1)), endColor: Color = Color(#colorLiteral(red: 0.009636783041, green: 0.9831244349, blue: 0.8203613162, alpha: 1)), size: CGFloat = 250) {
        self.vm = vm
        self._percent = State(initialValue: vm.percent)
        self.startColor = startColor
        self.endColor = endColor
        self.size = size
    }
    
    func animateRing(from oldPercent: Double, to newPercent: Double) {
        
        // Animation duration in seconds
        let animationDuration: Double = 0.3
        let frames: Double = 100.0
        
        let timePerFrame: Double = animationDuration / frames
        
        let percentDiff: Double = (newPercent - oldPercent)
        let percentPerFrame: Double = percentDiff / frames
        
        let _ = Timer.scheduledTimer(withTimeInterval: timePerFrame, repeats: true) { timer in
            if percentPerFrame > 0 && percent >= newPercent {
                percent = newPercent
                timer.invalidate()
            } else if percentPerFrame < 0 && percent <= newPercent {
                percent = newPercent
                timer.invalidate()
            } else {
                percent += percentPerFrame
            }
            
        }
    }
    
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
                            RingCutout(from: 0, to: cutoffPercent + 0.01, clockwise: false)
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
            .onChange(of: vm.percent) { newPercent in
                let oldPercent = percent
                animateRing(from: oldPercent, to: newPercent)
            }
        }
    }
}

struct GradientRing_Previews: PreviewProvider {
    static var vm: GradientRingViewModel = GradientRingViewModel(percent: 0.3)
    @State static var count: Int = 0
    
    static var previews: some View {
        Group {
            VStack {
                GradientRing(vm: vm)
                
                Button("Toggle") {
                    vm.percent = vm.percent < 0.5 ? 1.0 : 0.0
                    count += 1
                }
                
                Text("\(count)")
            }
            
            ZStack {
                Text("Test")
            }
        }
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
