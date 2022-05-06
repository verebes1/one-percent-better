//
//  Card.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 4/27/22.
//

import SwiftUI

struct Card: Identifiable {
    let id = UUID()
    let title: String
}

struct RowView: View {
    let cards: [Card]
    let width: CGFloat
    let height: CGFloat
    let horizontalSpacing: CGFloat
    var body: some View {
        HStack(spacing: horizontalSpacing) {
            ForEach(cards) { card in
                CardView(title: card.title)
                    .frame(width: width, height: height)
            }
        }
        .padding()
    }
}

struct RowView_Previews: PreviewProvider {
    static var previews: some View {
        let cards = Array(MockStore.cards[0..<3])
        RowView(cards: cards,
                width: 100,
                height: 100,
                horizontalSpacing: 6
        )
    }
}

