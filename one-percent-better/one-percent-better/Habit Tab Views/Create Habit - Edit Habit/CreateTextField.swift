//
//  CreateTextField.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 6/14/23.
//

import SwiftUI

struct CreateTextField: View {
   
   var placeholder: String
   @Binding var text: String
   var focus: FocusState<Bool>.Binding
   
    var body: some View {
       TextField(placeholder, text: $text)
          .focused(focus)
          .textInputAutocapitalization(.words)
          .padding(.leading, 20)
          .frame(height: 50)
          .background(Color.cardColor)
          .cornerRadius(radius: 10)
          .padding(.horizontal, 20)
    }
}

struct CreateTextField_Previews: PreviewProvider {
   @State static var text: String = ""
   @FocusState static var focus: Bool
   
   static var previews: some View {
      Background {
         CreateTextField(placeholder: "Name", text: $text, focus: $focus)
      }
   }
}
