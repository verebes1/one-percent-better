//
//  NumberTrackerEnterDataView.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 6/17/22.
//

import SwiftUI

struct NumberTrackerEnterDataView: View {
    
    let name: String
    @Binding var field: NumberTrackerFieldModel
    let index: Int
    let fieldsCount: Int
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(name)
                    .fontWeight(.medium)
                
                TextField("Value", text: $field.text)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
                    .frame(height: 45)
            }
            .padding(.horizontal, 20)
            
            if !field.validField {
                Label("Not a valid number", systemImage: "exclamationmark.triangle")
                    .foregroundColor(.red)
                    .padding(.bottom, (index != fieldsCount - 1) ? 5 : 0)
            }
            
            if index != fieldsCount - 1 {
                Divider()
            }
        }
    }
}

struct NumberTrackerEnterDataView_Previews: PreviewProvider {
    
    @State static var field = NumberTrackerFieldModel(text: "")
    
    static var previews: some View {
        Background {
            CardView {
                NumberTrackerEnterDataView(name: "Swimming", field: $field, index: 0, fieldsCount: 1)
            }
        }
    }
}
