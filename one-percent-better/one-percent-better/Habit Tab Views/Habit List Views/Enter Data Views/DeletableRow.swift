//
//  DeletableRow.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 9/19/22.
//

import SwiftUI

struct DeletableRow<Content>: View where Content: View {
    
    @State private var offset = CGSize.zero
    @State private var isDragging: Bool = false
    
    @State private var rightMenuOffset: CGFloat = 0
    
    var rightMenuOffsetPositive: CGFloat {
        max(0, rightMenuOffset)
    }
    
    @State private var rightMenuOpen = false
    var rightMenuWidth: CGFloat = 70
    
    var size: CGFloat = 30
    
    @State private var contentHeight: CGFloat = 0
    @State private var contentWidth: CGFloat = 0
    
    let content: () -> Content
    
    let deleteCallback: () -> Void
    
    var body: some View {
        
        let dragGesture = DragGesture()
            .onChanged { value in
                offset = value.translation
                if !rightMenuOpen {
                    rightMenuOffset = -offset.width
                } else {
                    rightMenuOffset = rightMenuWidth - offset.width
                }
            }
            .onEnded { _ in
                withAnimation {
                    if -offset.width > 50 {
                        rightMenuOpen = true
                        rightMenuOffset = rightMenuWidth
                    } else {
                        rightMenuOpen = false
                        rightMenuOffset = 0
                        offset = .zero
                    }
                }
                isDragging = false
            }
        
        ZStack {
            HStack {
                content()
                    .offset(x: -rightMenuOffsetPositive)
                    .overlay(
                        GeometryReader { geo in
                            Color.clear.onAppear {
                                self.contentHeight = geo.size.height
                            }
                        }
                    )
            }
            .background(Color.cardColor)
            .gesture(dragGesture)
            
            HStack {
                Spacer()
                Rectangle()
                    .fill(.red)
                    .frame(width: rightMenuOffsetPositive)
            }
            
            let trashWidth: CGFloat = min(23, contentHeight / 2)
            let rawTrashOffset = -rightMenuOffset + rightMenuWidth/2 + trashWidth/2
            let maxTrashOffset = -rightMenuWidth + rightMenuWidth/2 + trashWidth/2
            let trashOffset = rawTrashOffset < maxTrashOffset ? maxTrashOffset : rawTrashOffset
            
            HStack {
                Spacer()
                Image(systemName: "trash.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                .frame(width: trashWidth)
                .offset(x: trashOffset)
                .foregroundColor(.white)
                .onTapGesture {
                    deleteCallback()
                    withAnimation {
                        rightMenuOpen = false
                        rightMenuOffset = 0
                        offset = .zero
                    }
                }
            }
        }
        .clipped()
        .frame(height: contentHeight)
    }
}

struct DeletableRowPreview: View {
    
    @State private var rowText: String = "Hello World!"
    
    var body: some View {
        Background {
            DeletableRow {
                Text(rowText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 30)
            } deleteCallback: {
                rowText = "Deleted"
            }
        }
    }
}


struct DeletableRow_Previews: PreviewProvider {
    static var previews: some View {
        DeletableRowPreview()
    }
}
