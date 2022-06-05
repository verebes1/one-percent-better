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
    
    var lineWidth: CGFloat {
        size / 5
    }
    
    @State var completed: Bool = false
    
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 1)
                .stroke(Color.gray.opacity(0.25), style: .init(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .rotation3DEffect(.init(degrees: 180), axis: (x: 1, y: 0, z: 0))
                .rotation3DEffect(.init(degrees: -90), axis: (x: 0, y: 0, z: 1))
                .frame(width: size, height: size)
            
            Circle()
                .trim(from: completed ? 0.01 : 1-percent, to: 1)
                .stroke(color, style: .init(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .rotation3DEffect(.init(degrees: 180), axis: (x: 1, y: 0, z: 0))
                .rotation3DEffect(.init(degrees: -90), axis: (x: 0, y: 0, z: 1))
                .frame(width: size, height: size)
                .animation(.easeInOut, value: percent)
            
            if withText {
                Text("\(Int(round(100*percent)))%")
                    .font(.system(size: size/4))
                //                    .frame(width: 100, height: 100, alignment: .center)
            }
        }
        .padding(lineWidth/2)
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
