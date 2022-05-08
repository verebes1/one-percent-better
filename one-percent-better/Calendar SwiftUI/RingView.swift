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
    
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 1)
                .stroke(Color.gray.opacity(0.25), style: .init(lineWidth: size/5, lineCap: .round, lineJoin: .round))
                .rotation3DEffect(.init(degrees: 180), axis: (x: 1, y: 0, z: 0))
                .rotation3DEffect(.init(degrees: -90), axis: (x: 0, y: 0, z: 1))
                .animation(.easeOut)
                .frame(width: size, height: size)
            
            Circle()
                .trim(from: 1-percent, to: 1)
                .stroke(color, style: .init(lineWidth: size/5, lineCap: .round, lineJoin: .round))
                .rotation3DEffect(.init(degrees: 180), axis: (x: 1, y: 0, z: 0))
                .rotation3DEffect(.init(degrees: -90), axis: (x: 0, y: 0, z: 1))
                .animation(.easeOut)
                .frame(width: size, height: size)
            
            
            
            if withText {
                Text("\(Int(round(100*percent)))%")
                    .font(.system(size: size/4))
                //                    .frame(width: 100, height: 100, alignment: .center)
            }
        }.padding(4)
    }
}

struct RingView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            RingView(percent: 0.435)
                .padding(5)
                .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
            
            RingView(percent: 0.435,
                     withText: true)
        }
    }
}
