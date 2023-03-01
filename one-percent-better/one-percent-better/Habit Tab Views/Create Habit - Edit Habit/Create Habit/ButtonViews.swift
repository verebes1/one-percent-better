//
//  ButtonViews.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/12/22.
//

import SwiftUI

struct BottomButton: View {
   
   @Environment(\.colorScheme) var scheme
    
    let label: String
    
    var withBottomPadding: Bool = true
   
   private var textColor: Color {
      scheme == .light ? .white : .black
   }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Style.accentColor)
                .frame(height: 50)
                .padding(.horizontal, 20)
            Text(label)
                .fontWeight(.medium)
                .foregroundColor(textColor)
        }
        .padding(.bottom, withBottomPadding ? 10 : 0)
    }
}

struct BottomButton_Previews: PreviewProvider {
    
    @State static var label: String = ""
    
    static var previews: some View {
        VStack {
            BottomButton(label: "Test")
        }
    }
}

struct BottomButtonDisabledWhenEmpty: View {
   
   @Environment(\.colorScheme) var scheme
    
    let text: String
    @Binding var dependingLabel: String
    
    var withBottomPadding: Bool = true
   
   private var textColor: Color {
      scheme == .light ? .white : .black
   }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(dependingLabel.isEmpty ? .systemGray5 : Style.accentColor)
                .frame(height: 50)
                .padding(.horizontal, 20)
            Text(text)
                .fontWeight(.medium)
                .foregroundColor(dependingLabel.isEmpty ? .tertiaryLabel : textColor)
        }
        .padding(.bottom, withBottomPadding ? 10 : 0)
    }
}

struct BottomButtonEmptyMeansDisabled_Previews: PreviewProvider {
    
    @State static var label: String = ""
    
    static var previews: some View {
        VStack {
            TextField("Test", text: $label)
                .padding()
            BottomButtonDisabledWhenEmpty(text: "Test", dependingLabel: $label)
        }
    }
}

struct SkipButton: View {
    var body: some View {
        ZStack {
            Spacer()
                .frame(height: 50)
                .padding(.horizontal, 15)
            Text("Skip")
                .fontWeight(.bold)
                .foregroundColor(.green)
        }
        .padding(.bottom, 10)
    }
}

