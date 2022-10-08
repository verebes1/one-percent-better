//
//  TimelineScroll.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/2/22.
//

import SwiftUI

struct TimelineScroll: View {
    private var totalWidth: CGFloat = 50 * 20
    private var maxWidth: CGFloat = 100 * 20
    
    private var colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
    
    var entries = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
    
    @State private var totalTranslation: CGFloat = 0
    @State private var dragTranslation: CGFloat = 0
    
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { val in
                dragTranslation = totalTranslation + val.translation.width
            }
            .onEnded { val in
                totalTranslation += val.translation.width
                
                withAnimation(.easeOut(duration: 1.0)) {
                    dragTranslation +=  val.predictedEndTranslation.width - totalTranslation
                }
            }
    }
    
    var body: some View {
        VStack {
            HStack {
                ForEach(Array(entries.enumerated()), id: \.offset) { (i, entry) in
                    VStack {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(colors[i % (colors.count - 1)])
                        Text("\(entry)")
                            .frame(minWidth: 15)
                    }
                    .frame(minWidth: 30)
                }
            }
            .contentShape(Rectangle())
            .offset(x: dragTranslation, y: 0)
            .gesture(dragGesture)
        }
    }
}

struct TimelineScroll_Previews: PreviewProvider {
    static var previews: some View {
        TimelineScroll()
    }
}
