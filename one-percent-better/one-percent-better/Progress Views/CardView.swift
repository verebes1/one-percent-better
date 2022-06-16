//
//  CardView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/24/22.
//

import SwiftUI

struct CardView<Content>: View where Content: View {
    let content: () -> Content
    
    var body: some View {
        content()
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity)
        .background(Color.cardColor)
        .cornerRadius(10)
        .shadow(color: Color.cardColorOpposite.opacity(0.2), radius: 7)
        .padding(.horizontal, 10)
    }
}

struct CardTitle: View {
    var name: String
    
    init(_ name: String) {
        self.name = name
    }
    
    var body: some View {
        Text(name)
            .font(.system(size: 19))
            .fontWeight(.medium)
    }
}

struct SimpleCardTitle<Content>: View where Content: View {
    var name: String
    let content: () -> Content
    
    init(_ name: String, @ViewBuilder content: @escaping () -> Content) {
        self.name = name
        self.content = content
    }
    
    var body: some View {
        HStack {
            CardTitle(name)
            Spacer()
            content()
        }
        .padding(.horizontal, 20)
        .padding(.top, 5)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Background {
                VStack(spacing: 20) {
                    CardView {
                        VStack {
                            CardTitle("Test")
                            Spacer()
                                .frame(height: 100)
                            Text("Test Card")
                            Spacer()
                                .frame(height: 100)
                        }
                    }
                    
                    CardView {
                        Rectangle()
                            .frame(height: 100)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Background {
                VStack(spacing: 20) {
                    CardView {
                        VStack {
                            SimpleCardTitle("Balloon") {
                                Text("test")
                            }
                            Spacer()
                                .frame(height: 100)
                            Text("Test Card")
                            Spacer()
                                .frame(height: 100)
                        }
                    }
                    
                    CardView {
                        Rectangle()
                            .frame(height: 100)
                            .foregroundColor(.blue)
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}
