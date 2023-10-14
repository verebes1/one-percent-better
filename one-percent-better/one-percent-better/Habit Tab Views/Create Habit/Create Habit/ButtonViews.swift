//
//  ButtonViews.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/12/22.
//

import SwiftUI

struct AccentButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .fontWeight(.semibold)
            .foregroundColor(.labelOpposite)
            .frame(height: 50)
            .padding(.horizontal, 20)
            .background(Style.accentColor)
            .cornerRadius(radius: 10)
    }
}

extension View {
    func accentButtonStyle() -> some View {
        modifier(AccentButtonStyle())
    }
}

struct WideAccentButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .fontWeight(.semibold)
            .foregroundColor(.labelOpposite)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .padding(.horizontal, 20)
            .background(Style.accentColor)
            .cornerRadius(radius: 10)
            .padding(.bottom, 10)
            .padding(.horizontal, 20)
    }
}

extension View {
    func wideAccentButtonStyle() -> some View {
        modifier(WideAccentButtonStyle())
    }
}

struct BottomButtonDisabledWhenEmpty: View {
    
    @Environment(\.colorScheme) var scheme
    
    let text: String
    @Binding var dependingLabel: String
    
    var body: some View {
        Text(text)
            .fontWeight(.semibold)
            .foregroundColor(dependingLabel.isEmpty ? .tertiaryLabel : .labelOpposite)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .padding(.horizontal, 20)
            .background(dependingLabel.isEmpty ? .systemGray5 : Style.accentColor)
            .cornerRadius(radius: 10)
            .padding(.bottom, 10)
            .padding(.horizontal, 20)
    }
}


struct BottomButton_Previews: PreviewProvider {
    
    @State static var label: String = ""
    
    static var previews: some View {
        VStack {
            Button {
                print("1")
            } label: {
                Text("Continue")
                    .wideAccentButtonStyle()
            }
            
            Button {
                print("2")
            } label: {
                Text("Continue")
                    .accentButtonStyle()
            }

            BottomButtonDisabledWhenEmpty(text: "Disabled", dependingLabel: $label)
        }
    }
}
