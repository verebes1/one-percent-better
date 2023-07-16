//
//  ChangeAppearanceRow.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 12/15/22.
//

import SwiftUI

struct ChangeAppearanceRow: View {
   
   @EnvironmentObject var settings: Settings
   
   enum Appearance: Int, CustomStringConvertible {
      case system = 0
      case light = 1
      case dark = 2
      
      var description: String {
         switch self {
         case .light:
            return "Light"
         case .dark:
            return "Dark"
         case .system:
            return "System"
         }
      }
   }
   
   @Environment(\.managedObjectContext) var moc
   
   @State private var selectedAppearanceMenu: Appearance = .system
   
   var body: some View {
      HStack {
         // Maybe a whole view with an animated sun/moon which show and hide
         IconTextRow(title: "Appearance", icon: "moon.fill", color: .purple)
         Spacer()
         
         Menu {
            MenuItemWithCheckmark(value: Appearance.light, selection: $selectedAppearanceMenu)
            MenuItemWithCheckmark(value: Appearance.dark, selection: $selectedAppearanceMenu)
            MenuItemWithCheckmark(value: Appearance.system, selection: $selectedAppearanceMenu)
         } label: {
            HStack {
               Text(String(describing: selectedAppearanceMenu))
               Image(systemName: "chevron.down")
                  .resizable()
                  .aspectRatio(contentMode: .fit)
                  .frame(height: 6)
            }
            .fixedSize()
         }
         .onChange(of: selectedAppearanceMenu) { newValue in
            settings.appearance = selectedAppearanceMenu.rawValue
            moc.assertSave()
         }
      }
      .onAppear {
         selectedAppearanceMenu = Appearance(rawValue: settings.appearance) ?? .system
      }
   }
}

struct ChangeThemeRow_Previews: PreviewProvider {
   static var previews: some View {
      ChangeAppearanceRow()
   }
}
