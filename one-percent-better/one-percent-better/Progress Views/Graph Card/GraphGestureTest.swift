//
//  GraphGestureTest.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 6/19/22.
//

import SwiftUI

struct GraphGestureTest: View {
    
    
    @State private var position = CGPoint.zero
    @State private var offset = CGSize.zero
    @State private var isDragging: Bool = false
    
    @State private var isTouching: Bool = false
    
    var body: some View {
        
        let dragGesture = DragGesture()
            .onChanged { value in
                offset = value.translation
                position = value.location
            }
            .onEnded { _ in
                offset = .zero
                position = .zero
                isDragging = false
            }
        
        let longPressGesture = LongPressGesture()
            .onEnded { value in
                isDragging = true
            }
        
        let combinedGestures = longPressGesture.sequenced(before: dragGesture).onChanged { value in
            switch value {
            case .second(true, let drag):
                position = drag?.location ?? .zero
            default:
                break
            }
        }
        
        ScrollView {
            VStack {
                
                Spacer()
                    .frame(height: 250)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(isDragging ? .green : .red)
                    .gesture(combinedGestures)
                    
                    Circle()
                        .fill(.purple)
                        .frame(width: 30, height: 30)
                        .position(x: position.x, y: position.y)
//                        .offset(x: offset.width, y: 0)
                }
                
                Text("isDragging: \(String(describing: isDragging))")
                Text("position: \(String(describing: position))")
                
            }
        }
    }
}

struct GraphGestureTest_Previews: PreviewProvider {
    static var previews: some View {
        GraphGestureTest()
    }
}
