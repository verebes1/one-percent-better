//
//  GradientRing.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 7/5/22.
//

import SwiftUI


class GradientRingViewModel {
    
    /// The color at the start of the gradient
    var startColor = Color(#colorLiteral(red: 0, green: 0.7286170125, blue: 0.879304111, alpha: 1))
    
    /// The color at the end of the gradient
    var endColor = Color(#colorLiteral(red: 0.009636783041, green: 0.9831244349, blue: 0.8203613162, alpha: 1))
    
    /// The diameter of the circle
    var size: CGFloat = 250
    
    /// The line width of the circle
    var lineWidth: CGFloat = 50
    
    /// Opacity of the shadow on ends of the circle
    var shadowOpacity: Double = 0.15
    
    /// Radius of shadow at the ends of the circle
    var shadowRadius: CGFloat {
        lineWidth/4
    }
    
    let startAngle: CGFloat = 22
    let endAngle: CGFloat = 2
    var angularGradient: AngularGradient {
        AngularGradient(gradient: Gradient(colors: [endColor, startColor]),
                        center: .center,
                        startAngle: .init(degrees: startAngle),
                        endAngle: .init(degrees: 360 + endAngle))
    }
    
    init(startColor: Color, endColor: Color, size: CGFloat, lineWidth: CGFloat?) {
        self.startColor = startColor
        self.endColor = endColor
        self.size = size
        if lineWidth != nil {
            self.lineWidth = lineWidth!
        } else {
            self.lineWidth = size / 5
        }
    }
}

struct GradientRing: View, Animatable {
    
    /// The percent completion of the circle
    /// Last point before the two ends touch: 0.935
    var percent: Double
    
    /// Used to animate the circle
    var animatableData: Double {
        get { percent }
        set { percent = newValue }
    }
    
    /// The cutoff percent for the new overlapping ring to start
    let cutoffPercent: Double = 0.935
    
    /// The percent at which to stop progressing the circle and start rotating
    /// the circle to make it appear as if it's progressing
    let startRotation = 1.5
    
    /// Percent completion, but it cuts off at the start rotation percent
    var percentWithRotationCutoff: Double {
        percent < startRotation ? percent : startRotation
    }
    
    /// What angle the final part of the circle should be (the part past 0.935)
    var continueAngle: CGFloat {
        let continueAngle = percentWithRotationCutoff - cutoffPercent
        let result = continueAngle > 0 ? continueAngle : 0
        return result
    }
    
    var vm: GradientRingViewModel
    
    init(percent: Double,
         startColor: Color = Color(#colorLiteral(red: 0, green: 0.7286170125, blue: 0.879304111, alpha: 1)),
         endColor: Color = Color(#colorLiteral(red: 0.009636783041, green: 0.9831244349, blue: 0.8203613162, alpha: 1)),
         size: CGFloat = 250,
         lineWidth: CGFloat? = nil) {
        self.percent = percent
        vm = GradientRingViewModel(startColor: startColor,
                                   endColor: endColor,
                                   size: size,
                                   lineWidth: lineWidth)
    }
    
    var body: some View {
        VStack {
            let rotationDegrees = percent < startRotation ? 0 : 360 * (percent - startRotation)
            
            // Circle
            ZStack {
                
                GrayCircle(vm: vm)
                
                // Start circle
                if percent > cutoffPercent && percent < 1 {
                    StartCircle(vm: vm,
                                percent: percent,
                                cutoffPercent: cutoffPercent)
                }

                // Main Loop circle
                MainLoopCircle(vm: vm,
                               percent: percent,
                               cutoffPercent: cutoffPercent,
                               percentWithRotationCutoff: percentWithRotationCutoff)
                
                
                // Overlapping circle
                if percent > cutoffPercent {
                    OverlappingCircle(vm: vm,
                                      cutoffPercent: cutoffPercent,
                                      continueAngle: continueAngle)
                }
            }
            .rotationEffect(Angle(degrees: rotationDegrees))
        }
    }
}

struct GradientRing_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            GradientRing(percent: 0.00000001, size: 100)
            GradientRing(percent: 0.5, size: 100)
            GradientRing(percent: 0.935, size: 100)
            GradientRing(percent: 0.936, size: 100)
            GradientRing(percent: 1.0, size: 100)
        }
    }
}


struct GrayCircle: View {
    
    let vm: GradientRingViewModel
    
    var body: some View {
        Circle()
            .trim(from: 0, to: 1)
            .stroke(Color.gray.opacity(0.15), style: .init(lineWidth: vm.lineWidth, lineCap: .round, lineJoin: .round))
            .rotation3DEffect(.init(degrees: 180), axis: (x: 1, y: 0, z: 0))
            .rotation3DEffect(.init(degrees: -90), axis: (x: 0, y: 0, z: 1))
            .frame(width: vm.size, height: vm.size)
    }
}

struct StartCircle: View {
    
    let vm: GradientRingViewModel
    let percent: Double
    let cutoffPercent: Double
    
    var body: some View {
        ZStack {
            ZStack {
                Circle()
                  .trim(from: 0, to: 0.00001)
                    .stroke(vm.startColor, style: .init(lineWidth: vm.lineWidth, lineCap: .round, lineJoin: .round))
                    .rotation3DEffect(.init(degrees: 180), axis: (x: 1, y: 0, z: 0))
                    .rotation3DEffect(.init(degrees: -90), axis: (x: 0, y: 0, z: 1))
                    .shadow(color: percent > cutoffPercent ? .black.opacity(vm.shadowOpacity) : .black.opacity(0), radius: vm.shadowRadius)
                    .frame(width: vm.size, height: vm.size)
            }
            .frame(width: vm.size + vm.lineWidth, height: vm.size + vm.lineWidth)
            .clipShape(Circle())
        }
        .reverseMask {
            Circle()
                .frame(width: vm.size - vm.lineWidth, height: vm.size - vm.lineWidth)
        }
    }
}

struct MainLoopCircle: View {
    
    let vm: GradientRingViewModel
    let percent: Double
    let cutoffPercent: Double
    let percentWithRotationCutoff: Double
    
    var body: some View {
        ZStack {
            ZStack {
                Circle()
                    .trim(from: 1 - percentWithRotationCutoff, to: 1)
                    .stroke(vm.angularGradient, style: .init(lineWidth: vm.lineWidth, lineCap: .round, lineJoin: .round))
                    .rotation3DEffect(.init(degrees: 180), axis: (x: 1, y: 0, z: 0))
                    .rotation3DEffect(.init(degrees: -90), axis: (x: 0, y: 0, z: 1))
                    .shadow(color: .black.opacity(vm.shadowOpacity), radius: vm.shadowRadius)
                    .frame(width: vm.size, height: vm.size)
            }
            .frame(width: vm.size + vm.lineWidth, height: vm.size + vm.lineWidth)
            .reverseMask {
                if percent > cutoffPercent {
                    RingCutout(from: 0, to: cutoffPercent + 0.01, clockwise: false)
                }
            }
            .clipShape(Circle())
        }
        .reverseMask {
            Circle()
                .frame(width: vm.size - vm.lineWidth, height: vm.size - vm.lineWidth)
        }
    }
}

struct OverlappingCircle: View {
    
    var vm: GradientRingViewModel
    let cutoffPercent: Double
    let continueAngle: CGFloat
    
    var body: some View {
        ZStack {
            ZStack {
                let angleOffset: CGFloat = 360 - 360 * cutoffPercent
                Circle()
                    .trim(from: 0, to: continueAngle)
                    .stroke(vm.endColor, style: .init(lineWidth: vm.lineWidth, lineCap: .round, lineJoin: .round))
                    .rotation3DEffect(.init(degrees: -90 - angleOffset), axis: (x: 0, y: 0, z: 1))
                    .shadow(color: .black.opacity(vm.shadowOpacity), radius: vm.shadowRadius)
                    .frame(width: vm.size, height: vm.size)
            }
            .frame(width: vm.size + vm.lineWidth, height: vm.size + vm.lineWidth)
            .reverseMask {
                RingCutout(from: cutoffPercent, to: cutoffPercent - 0.1, clockwise: false)
            }
            .clipShape(Circle())
        }
        .reverseMask {
            Circle()
                .frame(width: vm.size - vm.lineWidth, height: vm.size - vm.lineWidth)
        }
    }
}

extension View {
    public dynamic func reverseMask<Mask: View>(
        alignment: Alignment = .center,
        @ViewBuilder _ mask: () -> Mask
    ) -> some View {
        self.mask {
            Rectangle()
                .overlay(alignment: alignment) {
                    mask()
                        .blendMode(.destinationOut)
                }
        }
    }
}

