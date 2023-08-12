//
//  LayoutTest.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 7/24/23.
//

import SwiftUI

struct LayoutTest: View {
   @State private var usesFixedSize = false
   var body: some View {
      VStack {
         Text("Hello, World!")
            .frame(idealWidth: 300)
            .fixedSize(horizontal: usesFixedSize, vertical: false)
            .background(.red)
         Toggle("Fixed sizes", isOn: $usesFixedSize.animation())
      }
   }
}

struct LayoutTest_Previews: PreviewProvider {
    static var previews: some View {
        LayoutTest()
    }
}
