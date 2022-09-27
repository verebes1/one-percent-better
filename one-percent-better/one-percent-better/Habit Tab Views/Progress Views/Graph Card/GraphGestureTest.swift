//
//  GraphGestureTest.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 6/19/22.
//

import SwiftUI

struct GraphGestureTest: View {
    
    @State private var isDragging: Bool = false
    @GestureState private var myGesture = CGPoint.zero
    
    var body: some View {
        
        let myDrag = DragGesture(minimumDistance: 0)
            .updating($myGesture) { currentState, gestureState, transaction in
                gestureState = currentState.location
            }
            .onChanged({ drag in
                isDragging = true
            })
            .onEnded { _ in
                isDragging = false
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
                        .gesture(myDrag)
                    
                    Circle()
                        .fill(.yellow)
                        .frame(width: 30, height: 30)
                        .position(x: myGesture.x, y: myGesture.y)
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
