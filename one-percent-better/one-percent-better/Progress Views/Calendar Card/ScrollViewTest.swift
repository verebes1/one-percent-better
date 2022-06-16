//
//  ScrollViewTest.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/25/22.
//

import SwiftUI

struct ScrollViewTest: View {
    var body: some View {
        ScrollView {
            LazyHStack {
                PageView()
            }
        }
    }
}

struct ScrollViewTest_Previews: PreviewProvider {
    static var previews: some View {
        ScrollViewTest()
    }
}



struct PageView: View {
    var body: some View {
        TabView {
            ForEach(0..<30) { i in
                ZStack {
                    Color.black
                    Text("Row: \(i)").foregroundColor(.white)
                }.clipShape(RoundedRectangle(cornerRadius: 10.0, style: .continuous))
            }
            .padding(.all, 10)
        }
        .frame(width: UIScreen.main.bounds.width)
        .tabViewStyle(PageTabViewStyle())
    }
}
