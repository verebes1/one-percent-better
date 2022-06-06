//
//  CreateNewHabit.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/17/22.
//

import SwiftUI

struct CreateNewHabit: View {
    
    @Environment(\.managedObjectContext) var moc
    
    @Binding var rootPresenting: Bool
    
    @State var habitName: String = ""
    @State var duplicateNameError: Bool = false
    @State private var isUsernameFirstResponder : Bool? = true
    @State private var isPasswordFirstResponder : Bool? =  false
    
    var body: some View {
        Background {
            VStack {
                HabitCreationHeader(systemImage: "square.and.pencil",
                                    title: "Create New Habit")
                
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.cardColor)
                            .frame(height: 50)
//                        TextField("Habit Name", text: $habitName)
//                            .padding(.leading, 10)
                        
                        CustomTextField(text: $habitName,
                                        nextResponder: $isPasswordFirstResponder,
                                        isResponder: $isUsernameFirstResponder,
                                        isSecured: false,
                                        keyboard: .default)
                            .padding(.leading, 10)
                            .frame(height: 50)
                    }
                    .padding(.horizontal, 20)
                    
                    if duplicateNameError {
                        Label("Habit name already exists", systemImage: "exclamationmark.triangle")
                            .foregroundColor(.red)
                            .animation(.easeInOut, value: duplicateNameError)
                    }
                }
                
                Spacer()
                
                BottomButton(text: "Create", dependingLabel: $habitName)
                    .onTapGesture {
                        duplicateNameError = false
                        if !habitName.isEmpty {
                            do {
                                let _ = try Habit(context: moc, name: habitName)
                            } catch HabitCreationError.duplicateName {
                                duplicateNameError = true
                            } catch {
                                print("ERROR: Habit creation error: \(error)")
                            }
                            
                            if !duplicateNameError {
                                try? moc.save()
                                rootPresenting = false
                            }
                        }
                    }
            }
        }
    }
}

struct CreateNewHabit_Previews: PreviewProvider {
    
    @State static var rootView: Bool = false
    
    static var previews: some View {
        let context = CoreDataManager.previews.persistentContainer.viewContext
        CreateNewHabit(rootPresenting: $rootView)
            .environment(\.managedObjectContext, context)
    }
}

struct BottomButton: View {
    
    let text: String
    @Binding var dependingLabel: String
    
    var withBottomPadding: Bool = true
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(dependingLabel.isEmpty ? .systemGray5 : .green)
                .frame(height: 50)
                .padding(.horizontal, 20)
            Text(text)
                .fontWeight(.bold)
                .foregroundColor(dependingLabel.isEmpty ? .tertiaryLabel : .white)
        }
        .padding(.bottom, withBottomPadding ? 10 : 0)
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


struct CustomTextField: UIViewRepresentable {

   class Coordinator: NSObject, UITextFieldDelegate {

      @Binding var text: String
      @Binding var nextResponder : Bool?
      @Binding var isResponder : Bool?

      init(text: Binding<String>, nextResponder : Binding<Bool?> , isResponder : Binding<Bool?>) {
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
         }
      }
    
      func textFieldDidEndEditing(_ textField: UITextField) {
         DispatchQueue.main.async {
             self.isResponder = false
             if self.nextResponder != nil {
                 self.nextResponder = true
             }
         }
      }
  }

  @Binding var text: String
  @Binding var nextResponder : Bool?
  @Binding var isResponder : Bool?

  var isSecured : Bool = false
  var keyboard : UIKeyboardType

  func makeUIView(context: UIViewRepresentableContext<CustomTextField>) -> UITextField {
      let textField = UITextField(frame: .zero)
      textField.isSecureTextEntry = isSecured
      textField.autocapitalizationType = .none
      textField.autocorrectionType = .no
      textField.keyboardType = keyboard
      textField.delegate = context.coordinator
      textField.placeholder = "Habit Name"
      textField.autocapitalizationType = .words
      return textField
  }

  func makeCoordinator() -> CustomTextField.Coordinator {
      return Coordinator(text: $text, nextResponder: $nextResponder, isResponder: $isResponder)
  }

  func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<CustomTextField>) {
       uiView.text = text
       if isResponder ?? false {
           uiView.becomeFirstResponder()
       }
  }

}
