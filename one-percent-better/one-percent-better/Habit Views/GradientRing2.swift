//
//  GradientRing2.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 7/8/22.
//

import SwiftUI

struct GradientRing2: View {
    
    var color: Color = .red
    var color2: Color = .green
    var color3: Color = .blue
    
    var size: CGFloat = 250
    var lineWidth: CGFloat {
        size/5
    }
    
    var percent: Double = 0.3
    
    var realPercent: Double {
        1 - percent
    }
    
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 1)
                .stroke(Color.gray.opacity(0.25), style: .init(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .rotation3DEffect(.init(degrees: 180), axis: (x: 1, y: 0, z: 0))
                .rotation3DEffect(.init(degrees: -90), axis: (x: 0, y: 0, z: 1))
                .frame(width: size, height: size)
            
            let gradient = AngularGradient(gradient: Gradient(colors: [color, color2]), center: .center)
            
            ZStack {
                ZStack {
                    Circle()
                        .trim(from: realPercent, to: 1)
                        .stroke(.green, style: .init(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                        .rotation3DEffect(.init(degrees: 180), axis: (x: 1, y: 0, z: 0))
                        .rotation3DEffect(.init(degrees: -90), axis: (x: 0, y: 0, z: 1))
                        .shadow(color: .black.opacity(0.4), radius: 10)
                    .frame(width: size, height: size)
                }
                .frame(width: size + lineWidth, height: size + lineWidth)
                .clipShape(Circle())
            }
            .reverseMask {
                Circle()
                    .frame(width: size - lineWidth, height: size - lineWidth)
            }
            
            let gradient2 = AngularGradient(gradient: Gradient(colors: [color, color3]), center: .center)
            
//            Circle()
//                .trim(from: 0, to: 0.2)
//                .stroke(.blue.opacity(0.5), style: .init(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
////                .rotation3DEffect(.init(degrees: 180), axis: (x: 1, y: 0, z: 0))
//                .rotation3DEffect(.init(degrees: -120), axis: (x: 0, y: 0, z: 1))
//                .frame(width: size, height: size)
            
            
            
//            let angle = (-percent*360 + 90)
//            let radians = angle*(2*pi) / 360
//            let xOff = size/2 * cos(radians)
//            let yOff = size/2 * sin(radians)
//
//            let circum = pi * size
//            let rectHeight: CGFloat = circum
//            let circDia: CGFloat = lineWidth
//
//            let halfScale = rectHeight / circDia / 2
//            let yGradStart = 0.5 - halfScale
//            let yGradEnd = 0.5 + halfScale
//
//            let scaling = 2 * (percent - 0.5)
//            let newGradStart = yGradStart - (scaling * -yGradStart)
//            let newGradEnd = yGradEnd - (scaling * -yGradStart)
//
//            let grad2 = LinearGradient(gradient: Gradient(colors: [startColor, endColor]), startPoint: .init(x: 0.5, y: newGradStart), endPoint: .init(x: 0.5, y: newGradEnd))
//
//
//            let startxOff = size/2 * cos(pi/2)
//            let startyOff = size/2 * sin(pi/2)
            
            // Beginning top semi-circle
//            Circle()
//                .trim(from: 0, to: 0.5)
//                .fill(.red)
////                .fill(color2)
//                .rotation3DEffect(.init(degrees: 90), axis: (x: 0, y: 0, z: 1))
//                .offset(x: startxOff, y: -startyOff)
//                .frame(width: lineWidth)

            // End semi-circle
//            Circle()
//                .trim(from: 0, to: 0.5)
////                .fill(grad2)
//                .fill(endColor)
////                .fill(.blue.opacity(0.6))
//                .rotation3DEffect(.init(degrees: -angle), axis: (x: 0, y: 0, z: 1))
//                .offset(x: xOff, y: -yOff)
//                .frame(width: lineWidth)
////                .shadow(radius: 10)
            
            // End trimmed circle
//            Circle()
//                .trim(from: 0, to: 0.04)
//                .stroke(endColor, style: .init(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
//                .rotation3DEffect(.init(degrees: 0), axis: (x: 1, y: 0, z: 0))
//                .rotation3DEffect(.init(degrees: -105), axis: (x: 0, y: 0, z: 1))
//                .frame(width: size, height: size)
//                .animation(.easeInOut, value: completed)
    
//            VStack {
//                Text("angle: \(angle)")
//                Text("radians: \(radians)")
//                Text("x: \(xOff)")
//            }
        }
    }
}

struct GradientRing2_Previews: PreviewProvider {
    static var previews: some View {
        GradientRing2()
    }
}


extension View {
//    @inlinable
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
