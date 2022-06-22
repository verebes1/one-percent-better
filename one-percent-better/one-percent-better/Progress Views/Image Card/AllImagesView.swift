//
//  AllImagesView.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 6/19/22.
//

import SwiftUI

struct AllImagesView: View {
    
    var images: [UIImage]
    
    let photoSpacing: CGFloat = 4
    var gridItem: GridItem {
        .init(.flexible(), spacing: photoSpacing)
    }
    var columns: [GridItem] {
        Array(repeating: gridItem, count: 5)
    }
    
    @State var showDetail: Bool = false
    @State var selectedIndex: Int = 0
    
    var body: some View {
        Background {
            ZStack {
                ScrollView {
                    VStack {
                        LazyVGrid(columns: columns, alignment: .center, spacing: photoSpacing) {
                            ForEach(0 ..< images.count, id: \.self) { i in
                                Color.clear
                                    .aspectRatio(1, contentMode: .fit)
                                    .overlay(
                                        Image(uiImage: images[i])
                                            .resizable()
                                            .scaledToFill()
                                        )
                                    .clipShape(Rectangle())
                                    .onTapGesture {
                                        showDetail = true
                                        selectedIndex = i
                                    }
                            }
                        }
                        .padding(.horizontal, photoSpacing)
                        Spacer()
                    }
                    .navigationTitle("Images")
                }
                .overlay {
                    showDetailView
                }
            }
        }
    }
    
    @ViewBuilder var showDetailView: some View {
        if showDetail {
            ImagesPagingView(images: images, showDetail: $showDetail, selectedIndex: $selectedIndex)
        }
    }
}

struct AllImagesView_Previews: PreviewProvider {
    static var previews: some View {
        let patio = UIImage(named: "patio-done")!
        let patioImages = Array<UIImage>(repeating: patio, count: 20)
        NavigationView {
            AllImagesView(images: patioImages)
        }
    }
}
