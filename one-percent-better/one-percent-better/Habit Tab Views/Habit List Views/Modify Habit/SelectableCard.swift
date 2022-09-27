//
//  SelectableCard.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 8/14/22.
//

import SwiftUI

enum FrequencySelection {
    case timesPerDay
    case daysInTheWeek
//    case everyXDays
}

struct SelectableCard<Content>: View where Content: View {
    
    @Binding var selection: FrequencySelection
    let type: FrequencySelection
    let content: () -> Content
    
    var body: some View {
        CardView {
            content()
        }
        .simultaneousGesture(
            TapGesture()
                .onEnded({
                    selection = type
                })
        )
//        .onTapGesture {
//            selection = type
//        }
        .overlay(content: {
        
//                ZStack {
//                    VStack {
//                        HStack {
//                            Spacer()
//                            CheckmarkToggleButton(state: selection == type)
//                                .padding(.trailing, 5)
//                                .padding(5)
//                        }
//                        Spacer()
//                    }
//                }
        
            selection == type ?
            RoundedRectangle(cornerRadius: 10)
                .stroke(.blue, lineWidth: 2)
                .padding(.horizontal, cardViewHorizontalInset)
            :
            nil
        })
    }
}

struct SelectableCardPreviewer: View {
    
    @State private var selection: FrequencySelection = .timesPerDay
    
    var body: some View {
        Background {
            VStack {
                SelectableCard(selection: $selection, type: .timesPerDay, content: {
                    VStack {
                        Text("Hello World")
                        Text("Hello World")
                        Text("Hello World")
                        Text("Hello World")
                    }
                })
                
                SelectableCard(selection: $selection, type: .daysInTheWeek, content: {
                    VStack {
                        Text("What's good baby")
                        Text("What's good baby")
                        Text("What's good baby")
                        Text("What's good baby")
                    }
                })
            }
        }
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
