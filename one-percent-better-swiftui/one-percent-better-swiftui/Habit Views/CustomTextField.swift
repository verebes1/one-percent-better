//
//  CustomTextField.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/7/22.
//

import SwiftUI


struct CustomTextFieldView: View {
    
    @State var name: String = ""
    
    @State var isFirstResponder: Bool? = true
    
    var body: some View {
        Background {
            CustomTextField(text: $name,
                            placeholder: "Name",
                            isResponder: $isFirstResponder,
                            nextResponder: .constant(nil))
        }
    }
}

struct CustomTextField_Previews: PreviewProvider {
    static var previews: some View {
        CustomTextFieldView()
    }
}


struct CustomTextField: UIViewRepresentable {
    
    class Coordinator: NSObject, UITextFieldDelegate {
        
        @Binding var text: String
        @Binding var isResponder: Bool?
        @Binding var nextResponder: Bool?
        
        init(text: Binding<String>, isResponder: Binding<Bool?>, nextResponder: Binding<Bool?>) {
            _text = text
            _isResponder = isResponder
            _nextResponder = nextResponder
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.isResponder = true
                self.nextResponder = false
            }
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
//            self.textFieldDidEndEditing(textField)
            
            DispatchQueue.main.async {
                self.isResponder = false
                if self.nextResponder != nil {
                    self.nextResponder = true
                }
            }
            
            return true
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
//            textField.resignFirstResponder()
            DispatchQueue.main.async {
                self.isResponder = false
//                if self.nextResponder != nil {
//                    self.nextResponder = true
//                }
            }
        }
    }
    
    @Binding var text: String
    var placeholder: String = ""
    @Binding var isResponder: Bool?
    @Binding var nextResponder: Bool?
    var isSecured: Bool = false
    var keyboard: UIKeyboardType = .default
    var textAlignment: NSTextAlignment = .left
    
    func makeUIView(context: UIViewRepresentableContext<CustomTextField>) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.isSecureTextEntry = isSecured
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.keyboardType = keyboard
        textField.delegate = context.coordinator
        textField.placeholder = placeholder
        textField.autocapitalizationType = .words
        textField.textAlignment = textAlignment
        return textField
    }
    
    func makeCoordinator() -> CustomTextField.Coordinator {
        return Coordinator(text: $text, isResponder: $isResponder, nextResponder: $nextResponder)
    }
    
    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<CustomTextField>) {
        uiView.text = text
        if let isResponder = isResponder {
            if isResponder {
                uiView.becomeFirstResponder()
            }
        }
    }
    
}
