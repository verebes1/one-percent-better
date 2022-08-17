//
//  SelectableCard.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 8/14/22.
//

import SwiftUI

struct SelectableCard<Content>: View where Content: View {
    
    @Binding var selection: Bool
    let content: () -> Content
    
    var body: some View {
        Background {
            CardView {
                content()
            }
            .overlay(content: {
                ZStack {
                    VStack {
                        HStack {
                            Spacer()
                            CheckmarkToggleButton(state: selection)
                                .padding(.trailing, 5)
                                .padding(5)
                        }
                        Spacer()
                    }
                }
            })
            .onTapGesture {
                selection.toggle()
            }
        }
    }
}

struct SelectableCardPreviewer: View {
    @State private var selection = false
    
    var body: some View {
        SelectableCard(selection: $selection, content: {
            VStack {
                Text("Hello World")
                Text("Hello World")
                Text("Hello World")
                Text("Hello World")
            }
        })
    }
}

struct SelectableCard_Previews: PreviewProvider {
    static var previews: some View {
        SelectableCardPreviewer()
    }
}


struct CheckmarkToggleButton: View {
    
    var state: Bool = true
    
    var body: some View {
        Image(systemName: state ? "checkmark.circle.fill" : "circle")
            .foregroundColor(.blue)
            .padding(.trailing, 5)
    }
}
