//
//  ImagesPagingView.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 6/20/22.
//

import SwiftUI

struct ImagesPagingView: View {
    var images: [UIImage]

    var body: some View {
        TabView {
            ForEach(0 ..< images.count, id: \.self) { i in
                Image(uiImage: images[i])
                    .resizable()
                    .scaledToFit()
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

struct ImagesPagingView_Previews: PreviewProvider {
    static var previews: some View {
        let patio = UIImage(named: "patio-done")!
        let patioImages = Array<UIImage>(repeating: patio, count: 20)
        ImagesPagingView(images: patioImages)
    }
}
