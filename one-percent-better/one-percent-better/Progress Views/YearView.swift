//
//  YearView.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 6/25/22.
//

import SwiftUI

struct YearView: View {
    
    let spacing: CGFloat = 3
    
    var columns: [GridItem] = Array(repeating: .init(.flexible(minimum: 10, maximum: 20), spacing: 3), count: 7)
    
    var body: some View {
        VStack {
            LazyHGrid(rows: columns, spacing: spacing) {
                ForEach(0 ..< 100) { i in
                    Rectangle()
                        .fill(Color.random)
                        .aspectRatio(1, contentMode: .fit)
                }
            }
            .frame(maxWidth: .infinity)
//            .frame(height: 200)
        }
    }
}

struct YearView_Previews: PreviewProvider {
    static var previews: some View {
        YearView()
    }
}
