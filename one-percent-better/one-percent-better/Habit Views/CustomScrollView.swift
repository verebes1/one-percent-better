//
//  CustomScrollView.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 8/5/22.
//

import SwiftUI

struct CustomScrollView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct CustomScrollView_Previews: PreviewProvider {
    static var previews: some View {
        CustomScrollView()
    }
}


struct WeekScrollView: UIViewRepresentable {
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        
    }
    
    func makeUIView(context: UIViewRepresentableContext<WeekScrollView>) -> UIScrollView {
        let scrollView = UIScrollView(frame: .zero)
//        scrollView.delegate
        return scrollView
    }
    
    func makeCoordinator() -> WeekScrollView.Coordinator {
        return Coordinator()
    }
    
    func updateUIView(_ uiView: UIScrollView, context: UIViewRepresentableContext<WeekScrollView>) {
        
    }
}
