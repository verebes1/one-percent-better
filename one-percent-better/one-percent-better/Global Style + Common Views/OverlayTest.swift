//
//  OverlayTest.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 11/29/22.
//

import SwiftUI

struct OverlayTest: View {
   
   @State private var showAlert = false
   
   var body: some View {
      Button {
         showAlert.toggle()
      } label: {
         Text("Overlay 1")
      }
      .alert(
         "Are you sure you want to delete?",
         isPresented: $showAlert
      ) {
         
         Button("Delete", role: .destructive) {
            // delete()
         }
         
      }
      
   }
}

struct OverlayTest_Previews: PreviewProvider {
   static var previews: some View {
      OverlayTest()
   }
}
