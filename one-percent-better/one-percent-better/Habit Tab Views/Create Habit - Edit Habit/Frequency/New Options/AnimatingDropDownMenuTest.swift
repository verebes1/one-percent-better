//
//  AnimatingDropDownMenuTest.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 1/9/23.
//

import SwiftUI

struct AnimatingDropDownMenuTest: View {
   
   @State private var beginningDay = "Saturday"
   
   var body: some View {
      Menu {
         MenuItemWithCheckmark(text: "Saturday",
                               selection: $beginningDay)
         
         MenuItemWithCheckmark(text: "Monday",
                               selection: $beginningDay)
      } label: {
         RoundedDropDownMenuButton(text: $beginningDay,
                                   color: .blue,
                                   fontSize: 15)
      }
//      .animation(.linear(duration: 1), value: beginningDay)
   }
}

struct AnimatingDropDownMenuTest_Previews: PreviewProvider {
   static var previews: some View {
      AnimatingDropDownMenuTest()
   }
}
