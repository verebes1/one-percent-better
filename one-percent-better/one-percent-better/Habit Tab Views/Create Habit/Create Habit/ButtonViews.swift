//
//  ButtonViews.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/12/22.
//

import SwiftUI

struct AccentButtonStyle: ButtonStyle {
    
    @Environment(\.colorScheme) var scheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .foregroundColor(.labelOpposite)
            .frame(height: 50)
            .padding(.horizontal, 20)
            .background(Style.accentColor)
            .cornerRadius(radius: 10)
            .opacity(configuration.isPressed ?
                     (scheme == .light ? 0.2 : 0.4)
                     : 1)
    }
}

extension ButtonStyle where Self == AccentButtonStyle {
    static var accent: AccentButtonStyle {
        AccentButtonStyle()
    }
}

struct WideAccentButtonStyle: ButtonStyle {
    
    @Environment(\.colorScheme) var scheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .foregroundColor(.labelOpposite)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .padding(.horizontal, 20)
            .background(Style.accentColor)
            .cornerRadius(radius: 10)
            .padding(.bottom, 10)
            .padding(.horizontal, 20)
            .opacity(configuration.isPressed ?
                     (scheme == .light ? 0.2 : 0.4)
                     : 1)
    }
}

extension ButtonStyle where Self == WideAccentButtonStyle {
    static var wideAccent: WideAccentButtonStyle {
        WideAccentButtonStyle()
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
                print("0")
            } label: {
                Text("Continue")
            }
            .buttonStyle(.accent)

            
            Button {
                print("1")
            } label: {
                Text("Continue")
            }
            .buttonStyle(.wideAccent)

            BottomButtonDisabledWhenEmpty(text: "Disabled", dependingLabel: $label)
        }
    }
}
