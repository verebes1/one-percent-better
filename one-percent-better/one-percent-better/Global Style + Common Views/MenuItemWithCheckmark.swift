//
//  MenuItemWithCheckmark.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 1/15/23.
//

import SwiftUI

struct MenuItemWithCheckmark<Value>: View where Value: Equatable {
   var value: Value
   
   /// This item will have a checkmark
   @Binding var selection: Value

   var body: some View {
      Button {
         selection = value
      } label: {
         Label(String(describing: value),
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
