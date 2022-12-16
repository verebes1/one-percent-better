//
//  DayWeekMonthDropDown.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 12/14/22.
//

import SwiftUI

struct DayWeekMonthDropDown: View {
   
   @State private var showDropdown = false
   @State private var selectedItem = "Day"
   
   var body: some View {
      HStack {
         Text("Day")
            .font(.system(size: 20, weight: .regular, design: .rounded))
         
         Image(systemName: "chevron.down")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 12)
      }
      .padding(.vertical, 8)
      .padding(.horizontal, 15)
      .foregroundColor(.white)
      .background(Color.red)
      .clipShape(Capsule())
      
//      VStack {
//         HStack {
//            Picker(selection: $selectedItem, label: Text("Select an item")) {
//               Text("Day").tag("Day")
//               Text("Week").tag("Week")
//               Text("Month").tag("Month")
//            }
//            .pickerStyle(.menu)
////            Image(systemName: "chevron.down")
////               .resizable()
////               .aspectRatio(contentMode: .fit)
////               .frame(width: 12)
//         }
//         .padding(5)
//         .clipShape(Capsule())
//         .overlay(
//            Capsule()
//               .stroke(Style.accentColor, lineWidth: 2)
//         )
//         .onTapGesture {
//            showDropdown = true
//         }
//      }
   }
}

struct DayWeekMonthDropDown_Previews: PreviewProvider {
   static var previews: some View {
      DayWeekMonthDropDown()
   }
}
