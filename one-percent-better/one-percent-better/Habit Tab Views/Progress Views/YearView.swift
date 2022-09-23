//
//  YearView.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 6/25/22.
//

import SwiftUI

struct YearView: View {
    
    let insets: CGFloat = 15
    
    var body: some View {
        CardView {
            VStack {
                let spacing: CGFloat = 1
                let screenWidth = UIScreen.main.bounds.width - insets * 2
                let squareWidth: CGFloat = ((screenWidth - 51*spacing) / 52.0)
                let columns: [GridItem] = Array(repeating: GridItem(.fixed(squareWidth), spacing: spacing, alignment: .top), count: 7)
                
                LazyHGrid(rows: columns, spacing: spacing) {
                    ForEach(0 ..< 364) { i in
                        Rectangle()
                            .fill(Color.random)
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: squareWidth, height: squareWidth)
                    }
                }
//                .frame(width: UIScreen.main.bounds.width - insets * 2)
                .frame(width: 200)
                .frame(height: 50)
                .padding(.horizontal, insets)
            }
        }
    }
}

struct YearView_Previews: PreviewProvider {
    static var previews: some View {
        YearView()
    }
}
