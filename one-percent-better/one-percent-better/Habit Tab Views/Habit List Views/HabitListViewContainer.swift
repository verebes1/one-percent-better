//
//  HabitListViewContainer.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 4/11/23.
//

import SwiftUI

class SelectedDayModel: ObservableObject {
   
   @Published var selectedDay = Date()
   
   /// The latest day that has been shown. This is updated when the
   /// app is opened or the view appears on a new day.
   @Published var latestDay: Date = Date()
   
   /// Date formatter for the month year label at the top of the calendar
   var dateTitleFormatter: DateFormatter = {
      let dateFormatter = DateFormatter()
      dateFormatter.calendar = Calendar(identifier: .gregorian)
      dateFormatter.locale = Locale.autoupdatingCurrent
      dateFormatter.setLocalizedDateFormatFromTemplate("EEEE, MMM d, YYYY")
      return dateFormatter
   }()
   
   var navTitle: String {
      dateTitleFormatter.string(from: selectedDay)
   }
}

struct HabitListViewContainer: View {
   
   @Environment(\.scenePhase) var scenePhase
   
   @EnvironmentObject var hlvm: HabitListViewModel
   @EnvironmentObject var hwvm: HeaderWeekViewModel
   
   @StateObject var selectedDayModel = SelectedDayModel()
   
   var body: some View {
      Background {
         VStack {
            HabitsHeaderView()
            HabitListView(habits: hlvm.habits)
         }
      }
      .environmentObject(selectedDayModel)
   }
}

struct HabitListViewContainer_Previews: PreviewProvider {
   static var previews: some View {
      HabitListViewContainer()
   }
}
