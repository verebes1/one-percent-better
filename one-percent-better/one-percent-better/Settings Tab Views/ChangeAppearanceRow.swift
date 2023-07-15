//
//  ChangeAppearanceRow.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 12/15/22.
//

import SwiftUI

struct ChangeAppearanceRow: View {
   
   @AppStorage("selectedAppearance") var selectedAppearance = 0
   @State private var selectedAppearanceMenu: String = "System"
   
   var body: some View {
      HStack {
         // Maybe a whole view with an animated sun/moon which show and hide
         IconTextRow(title: "Appearance", icon: "moon.fill", color: .purple)
         Spacer()
         
         Menu {
            MenuItemWithCheckmark(value: "Light", selection: $selectedAppearanceMenu)
            MenuItemWithCheckmark(value: "Dark", selection: $selectedAppearanceMenu)
            MenuItemWithCheckmark(value: "System", selection: $selectedAppearanceMenu)
         } label: {
            HStack {
               Text(selectedAppearanceMenu)
                  .fixedSize()
               Image(systemName: "chevron.down")
                  .resizable()
                  .aspectRatio(contentMode: .fit)
                  .frame(height: 6)
            }
         }
         .onChange(of: selectedAppearanceMenu) { newValue in
            switch selectedAppearanceMenu {
            case "Light":
               selectedAppearance = 1
            case "Dark":
               selectedAppearance = 2
            default:
               selectedAppearance = 0
            }
         }
      }
   }
}

struct ChangeThemeRow_Previews: PreviewProvider {
   static var previews: some View {
      ChangeAppearanceRow()
   }
}
