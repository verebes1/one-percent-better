//
//  NewListView.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 6/19/23.
//

import SwiftUI

struct Blur: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemMaterial

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

struct NewListView: View {
   
   var habits = ["Run", "Cook", "Eat healthy"]
   
   var body: some View {
      ZStack {
         LinearGradient(colors: [.blue, .green, .cyan], startPoint: .init(x: 0, y: 1), endPoint: .init(x: 0, y: -1))
         
         List {
            ForEach(habits, id: \.self) { habit in
               Text(habit)
                  .foregroundColor(.black)
                  .listRowBackground(Blur(style: .systemThinMaterial))
            }
         }
         .scrollContentBackground(.hidden)
      }
   }
}

struct NewListView_Previews: PreviewProvider {
   static var previews: some View {
      NewListView()
   }
}
