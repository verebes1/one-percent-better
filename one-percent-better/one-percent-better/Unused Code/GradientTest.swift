//
//  GradientTest.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 7/5/22.
//

import SwiftUI

struct GradientTest: View {
    
    var color: Color = Color(#colorLiteral(red: 0.8811600804, green: 0, blue: 0.08062588423, alpha: 1))
    var color2: Color = .green
    
    var body: some View {
        VStack {
            ZStack {
                
                let gradient = AngularGradient(gradient: Gradient(colors: [color2, color]), center: .init(x: 0.5, y: 0.5))
                
                let grad = LinearGradient(colors: [color2, color], startPoint: .top, endPoint: .bottom)
                
                let rectHeight: CGFloat = 600
                let circDia: CGFloat = 100
                HStack {
                    Spacer().frame(width: circDia / 1.5)
                    ZStack {
                        Rectangle()
                            .fill(grad)
                        .frame(height: rectHeight)
                    }
//                    .mask {
//                       LinearGradient(gradient: Gradient(colors: [.black, .clear]), startPoint: .bottom, endPoint: .top)
//                    }
                }
                
                let percent: Double = 0.35
                let yOff = percent * (rectHeight - circDia) - (rectHeight / 2 - circDia / 2)
                
                let halfScale = rectHeight / circDia / 2
                let yGradStart = 0.5 - halfScale
                let yGradEnd = 0.5 + halfScale
                
                let scaling = 2 * (percent - 0.5)
                let newGradStart = yGradStart - (scaling * -yGradStart)
                let newGradEnd = yGradEnd - (scaling * -yGradStart)
                
                VStack {
                    Spacer()
                    Text("full scale: \(halfScale*2)")
                    Text("\(newGradStart), \(newGradEnd)")
                }
                
                let grad2 = LinearGradient(gradient: Gradient(colors: [color2, color]), startPoint: .init(x: 0.5, y: newGradStart), endPoint: .init(x: 0.5, y: newGradEnd))
                
                HStack {
                    Circle()
                        .fill(grad2)
                        .frame(width: circDia, height: circDia)
                    .offset(y: yOff)
                    Spacer()
                }
    //                .border(.black)
            }
        }
        
    }
}

struct GradientTest_Previews: PreviewProvider {
    static var previews: some View {
        GradientTest()
        
    }
}
