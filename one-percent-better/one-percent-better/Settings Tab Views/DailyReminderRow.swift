//
//  DailyReminderRow.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/20/22.
//

import SwiftUI

struct DailyReminderRow: View {
   
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
          IconTextRow(title: "Daily Reminder", icon: "bell.fill", color: .pink)
          Spacer()
          if vm.settings.dailyReminderEnabled {
             Text("\(formatter.string(from: vm.settings.dailyReminderTime))")
                .foregroundColor(.secondaryLabel)
          } else {
             Text("None")
                .foregroundColor(.secondaryLabel)
          }
       }
    }
}

struct DailyReminderRow_Previews: PreviewProvider {
    static var previews: some View {
        DailyReminderRow()
    }
}