//
//  ImagesPagingView.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 6/20/22.
//

import SwiftUI

struct ImagesPagingView: View {
    var images: [UIImage]
    
    @Binding var showDetail: Bool
    @Binding var selectedIndex: Int

    var body: some View {
        if showDetail {
            Background {
                VStack {
                    Button("Done") {
                        showDetail = false
                    }
                    TabView(selection: $selectedIndex) {
                        ForEach(0 ..< images.count, id: \.self) { i in
                            Image(uiImage: images[i])
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                .navigationBarHidden(true)
            }
        }
    }
}

struct ImagesPagingView_Previews: PreviewProvider {
    
    @State static var showDetail: Bool = true
    @State static var selectedIndex: Int = 0
    
    static var previews: some View {
        let patio = UIImage(named: "patio-done")!
        let patioImages = Array<UIImage>(repeating: patio, count: 20)
        ImagesPagingView(images: patioImages, showDetail: $showDetail, selectedIndex: $selectedIndex)
    }
}
