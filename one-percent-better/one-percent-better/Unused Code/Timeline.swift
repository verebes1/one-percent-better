//
//  Timeline.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 9/30/22.
//

import SwiftUI

struct Timeline: View {
    
    private var totalWidth: CGFloat = 50 * 20
    
    private var maxWidth: CGFloat = 100 * 20
    
    private var minWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    private var minScale: CGFloat {
        UIScreen.main.bounds.width / self.totalWidth
    }
    
    private var maxScale: CGFloat {
        maxWidth / self.totalWidth
    }
    
    let dampen = 0.5
    
    private var colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
    
    @State private var scale = 1.0
    @State private var newScale: CGFloat = 1.0
    @State private var lastBeforeClamp: CGFloat? = 1.0
    
    @State private var offsetFromZoom: CGFloat = 0.0
    
    @State private var scrollTest: CGFloat = 0.0
    
    func taper(curScale: CGFloat, zoomIn: Bool, c: CGFloat, b: CGFloat) -> CGFloat {
        // Get magnification on a scale from [0,1]
        // where 0 = max magnification where UI is still in bounds
        // and   1 = min magnification
        //
        // example: lastBeforeClamp = 50
        //          val = 35
        //          50 - 50 / 50 = 0  / 50 = 0
        //          50 - 35 / 50 = 15 / 50 = 0.3
        //          50 - 0  / 50 = 50 / 50 = 1.0
        let dx = (lastBeforeClamp! - curScale)
        let sign: CGFloat = (zoomIn ? 1 : -1)
        let x = sign * dx / lastBeforeClamp!
        
        // Plug this into the function f(x) = (e^(-bx) - 1) * (1 - c) + 1
        // where    c = The limit of magnification to stop at when rel = 0 (for example 70% = 0.7)
        //          b = how quickly the function tapers from 1 to c (1 = slowest, 50 = fast)
        let f1 = -1 * b * x
        let f2 = exp(f1)
        let f = (f2 - 1) * (1 - c) + 1
        return f
    }
    
    var magnification: some Gesture {
        MagnificationGesture()
            .onChanged { val in

                let curScale = scale * val
                let newWidth = totalWidth * curScale

                // If first magnification value makes (newWidth < screen width) then make this last before clamp
                if lastBeforeClamp == nil {
                    if newWidth < minWidth {
                        lastBeforeClamp = minScale
                    } else if newWidth > maxWidth {
                        lastBeforeClamp = maxScale
                    } else {
                        lastBeforeClamp = curScale
                    }
                }
                
                if newWidth < minWidth {
                    let f = taper(curScale: curScale,
                                  zoomIn: true,
                                  c: 0.8,
                                  b: 3.0)
                    
                    newScale = lastBeforeClamp! * f
                    
                    let adjustedWidth = newScale * totalWidth
                    offsetFromZoom = (minWidth - adjustedWidth) / 2
                    
                } else if newWidth > maxWidth {
                    let f = taper(curScale: curScale,
                                  zoomIn: false,
                                  c: 1.3,
                                  b: 0.5)
                    
                    newScale = lastBeforeClamp! * f
                    
                    let adjustedWidth = newScale * totalWidth
                    scrollTest = (adjustedWidth - maxWidth) / 2
                } else {
                    self.lastBeforeClamp = curScale
                    self.newScale = curScale
                }
                
                
            }
            .onEnded { _ in
                
                let newWidth = (totalWidth * newScale)
                let duration = 0.3
                if newWidth < minWidth {
                    withAnimation(.easeOut(duration: duration)) {
                        newScale = minScale
                        offsetFromZoom = 0
                    }
                } else if newWidth > maxWidth {
                    withAnimation(.easeOut(duration: duration)) {
                        newScale = maxScale
                        scrollTest = 0
                    }
                }
                
                scale = newScale
                lastBeforeClamp = nil
                
//                print("ENDED!")
            }
    }
    
    var entries = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
    
    var body: some View {
        VStack {
            Text("newScale: \(newScale)")
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: true) {
                    
                    HStack {
                        ForEach(Array(entries.enumerated()), id: \.offset) { (i, entry) in
                            VStack {
                                RoundedRectangle(cornerRadius: 5)
                                    .foregroundColor(colors[i % (colors.count - 1)])
                                Text("\(entry)")
                            }
                        }
                    }
                    .contentShape(Rectangle())
                    .frame(width: totalWidth * newScale)
                    .offset(x: scrollTest, y: 0)
                    .gesture(magnification)
                }
                .offset(x: offsetFromZoom, y: 0)
            }
        }
    }
}

struct Timeline_Previews: PreviewProvider {
    static var previews: some View {
        Timeline()
    }
}
