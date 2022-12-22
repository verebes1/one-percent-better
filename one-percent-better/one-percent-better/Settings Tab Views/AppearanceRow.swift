//
//  AppearanceRow.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 12/22/22.
//

import SwiftUI

struct AppearanceRow: View {
   
   @EnvironmentObject var vm: SettingsViewModel
   
   var formatter: DateFormatter {
      let formatter = DateFormatter()
      formatter.locale = Locale(identifier: "en_US_POSIX")
      formatter.dateFormat = "h:mm a"
      formatter.amSymbol = "AM"
      formatter.pmSymbol = "PM"
      return formatter
   }
   
   var body: some View {
      HStack {
         IconTextRow(title: "Appearance", icon: "bell.fill", color: .pink)
         Spacer()
         if let settings = vm.settings,
            settings.dailyReminderEnabled {
            Text("\(formatter.string(from: settings.dailyReminderTime))")
               .foregroundColor(.secondaryLabel)
         } else {
            Text("None")
               .foregroundColor(.secondaryLabel)
         }
      }
   }
}

struct AppearanceRow_Previews: PreviewProvider {
   static func data() {
      let context = CoreDataManager.previews.mainContext
      let _ = Settings(context: context)
   }
   
   static var previews: some View {
      let moc = CoreDataManager.previews.mainContext
      let _ = data()
      AppearanceRow()
         .environmentObject(SettingsViewModel(moc))
   }
}

