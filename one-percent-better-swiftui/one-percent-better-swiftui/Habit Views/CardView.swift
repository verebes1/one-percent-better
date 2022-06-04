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

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Background {
                VStack(spacing: 20) {
                    CardView {
                        VStack {
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
