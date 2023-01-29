//
//  PickerMenuTest.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 12/15/22.
//

import SwiftUI

struct PickerMenuTest: View {
   
   var body: some View {
      Menu {
          Button("Open in Preview", action: {})
          Button("Save as PDF", action: {})
      } label: {
          Label("PDF", systemImage: "doc.fill")
      }
   }
}

struct PickerMenuTest_Previews: PreviewProvider {
   static var previews: some View {
      PickerMenuTest()
   }
}

