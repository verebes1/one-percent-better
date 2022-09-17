//
//  TextFieldTests.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/13/22.
//

import SwiftUI

struct TextFieldTests: View {
    
    enum Field: Hashable {
        case field1
        case field2
    }
    
    @State var text1: String = ""
    @State var text2: String = ""
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack {
            Text("Focused: \(String(describing: focusedField))")
            TextField("Test1", text: $text1)
                .focused($focusedField, equals: .field1)
                .background(.green.opacity(0.1))
                .padding()
                
            TextField("Test2", text: $text2)
                .focused($focusedField, equals: .field2)
                .background(.green.opacity(0.1))
                .padding()
        }
    }
}

struct TextFieldTests_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldTests()
    }
}
