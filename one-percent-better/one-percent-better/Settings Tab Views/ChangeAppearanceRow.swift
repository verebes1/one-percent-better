//
//  ChangeAppearanceRow.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 12/15/22.
//

import SwiftUI

struct ChangeAppearanceRow: View {
   
   @EnvironmentObject var vm: SettingsViewModel
   
    var body: some View {
       HStack {
          IconTextRow(title: "Appearance", icon: "moon.fill", color: .blue)
          Spacer()
          Text("System")
             .foregroundColor(.secondaryLabel)
       }
    }
}

struct ChangeThemeRow_Previews: PreviewProvider {
    static var previews: some View {
        ChangeAppearanceRow()
    }
}
