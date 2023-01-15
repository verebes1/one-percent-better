//
//  MenuItemWithCheckmark.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 1/15/23.
//

import SwiftUI

struct MenuItemWithCheckmark<T>: View where T: Equatable {
   var value: T
   @Binding var selection: T
   
   var stringValue: String {
      "\(value)"
   }

   var body: some View {
      Button {
         selection = value
      } label: {
         Label(stringValue,
               systemImage: value == selection ? "checkmark" : "")
      }
   }
}

struct MenuItemWithCheckmark_Previewer: View {
   
   @State private var selection = 0
   
   var body: some View {
      Menu("Select a number") {
         MenuItemWithCheckmark(value: 0, selection: $selection)
         MenuItemWithCheckmark(value: 1, selection: $selection)
         MenuItemWithCheckmark(value: 2, selection: $selection)
         MenuItemWithCheckmark(value: 3, selection: $selection)
      }
   }
}

struct MenuItemWithCheckmark_Previews: PreviewProvider {
    static var previews: some View {
       MenuItemWithCheckmark_Previewer()
    }
}
