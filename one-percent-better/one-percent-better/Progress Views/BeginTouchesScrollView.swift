//
//  BeginTouchesScrollView.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 6/19/22.
//

import SwiftUI

struct BeginTouchesScrollView: UIViewRepresentable {
    
    func makeUIView(context: UIViewRepresentableContext<BeginTouchesScrollView>) -> UIView {
        let scrollView = CustomScrollView(frame: .zero)
        return scrollView
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<BeginTouchesScrollView>) {
        // Do nothing
    }
    
    class CustomScrollView: UIScrollView {
        
        override func touchesShouldBegin(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView) -> Bool {
//            if let graphView = view as? GraphUIKitView {
//                graphView.beginTouches(touches, with: event)
//            }
            return super.touchesShouldBegin(touches, with: event, in: view)
        }
    }

}


struct BeginTouchesScrollView_Previews: PreviewProvider {
    static var previews: some View {
        BeginTouchesScrollView()
    }
}
