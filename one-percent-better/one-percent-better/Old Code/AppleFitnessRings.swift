//
//  AppleFitnessRings.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 7/25/22.
//

import SwiftUI

struct AppleFitnessRings: View {
    
    @State private var percent1: Double = 1.5
    @State private var percent2: Double = 1.5
    @State private var percent3: Double = 1.5
    
    var red1 = Color(#colorLiteral(red: 0.8853258491, green: 0, blue: 0.0789533928, alpha: 1))
    var red2 = Color(#colorLiteral(red: 1, green: 0.1921028495, blue: 0.5405147672, alpha: 1))
    
    var yellow1 = Color(#colorLiteral(red: 0.2320876718, green: 0.8590276837, blue: 0.01154122502, alpha: 1))
    var yellow2 = Color(#colorLiteral(red: 0.7370175719, green: 0.9994353652, blue: 0.02015792951, alpha: 1))
    
    var blue1 = Color(#colorLiteral(red: 0, green: 0.7327416539, blue: 0.9001016021, alpha: 1))
    var blue2 = Color(#colorLiteral(red: 0, green: 0.9871314168, blue: 0.8243331909, alpha: 1))
    
    var duration: Double = 2.0
    
    var body: some View {
        VStack {
            ZStack {
                GradientRing(percent: percent1,
                             startColor: red1,
                             endColor:  red2,
                             size: 300,
                             lineWidth: 35)
                .animation(.easeInOut(duration: duration), value: percent1)
                
                GradientRing(percent: percent2,
                             startColor: yellow1,
                             endColor:  yellow2,
                             size: 225,
                             lineWidth: 35)
                .animation(.easeInOut(duration: duration), value: percent2)
                
                GradientRing(percent: percent3,
                             startColor: blue1,
                             endColor:  blue2,
                             size: 150,
                             lineWidth: 35)
                .animation(.easeInOut(duration: duration), value: percent3)
            }
            
            Button("Random") {
                percent1 = Double.random(in: 0 ... 2)
                percent2 = Double.random(in: 0 ... 2)
                percent3 = Double.random(in: 0 ... 2)
            }
        }
    }
}

struct AppleFitnessRings_Previews: PreviewProvider {
    static var previews: some View {
        AppleFitnessRings()
            .preferredColorScheme(.dark)
    }
}
