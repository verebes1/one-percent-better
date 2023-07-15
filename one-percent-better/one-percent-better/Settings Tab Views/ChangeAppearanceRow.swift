//
//  ChangeAppearanceRow.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 12/15/22.
//

import SwiftUI

struct ChangeAppearanceRow: View {
   
   @EnvironmentObject var settings: Settings
   
   @Environment(\.managedObjectContext) var moc
   
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
               settings.appearance = 1
            case "Dark":
               settings.appearance = 2
            default:
               settings.appearance = 0
            }
            moc.assertSave()
         }
      }
      .onAppear {
         switch settings.appearance {
         case 1:
            selectedAppearanceMenu = "Light"
         case 2:
            selectedAppearanceMenu = "Dark"
         default:
            selectedAppearanceMenu = "System"
         }
      }
   }
}

struct ChangeThemeRow_Previews: PreviewProvider {
   static var previews: some View {
      ChangeAppearanceRow()
   }
}
