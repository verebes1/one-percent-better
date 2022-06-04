//
//  BlurView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/4/22.
//

import SwiftUI

struct BlurView: UIViewRepresentable {

    let style: UIBlurEffect.Style

    func makeUIView(context: UIViewRepresentableContext<BlurView>) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blurView, at: 0)
        NSLayoutConstraint.activate([
            blurView.heightAnchor.constraint(equalTo: view.heightAnchor),
            blurView.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
        return view
    }

    func updateUIView(_ uiView: UIView,
                      context: UIViewRepresentableContext<BlurView>) {

    }

}

struct BlurView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ZStack {
                List(1..<100) { item in
                    Rectangle().foregroundColor(Color.pink)
                }
                .navigationBarTitle(Text("A List"))
                ZStack {
                    BlurView(style: .light)
                        .frame(width: 300, height: 300)
                    Text("Hey there, I'm on top of the blur")
                    
                }
            }
        }
    }
}
