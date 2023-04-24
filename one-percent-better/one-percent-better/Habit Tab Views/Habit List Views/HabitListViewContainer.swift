//
//  HabitListViewContainer.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 4/11/23.
//

import SwiftUI

class SelectedDayModel: ObservableObject, Equatable {
   
   @Published var selectedDay = Date()
   
   /// The latest day that has been shown. This is updated when the
   /// app is opened or the view appears on a new day.
   @Published var latestDay: Date = Date()
   
   static func == (lhs: SelectedDayModel, rhs: SelectedDayModel) -> Bool {
      lhs.selectedDay == rhs.selectedDay &&
      lhs.latestDay == rhs.selectedDay
   }
   
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
   
   func updateDayToToday() {
      if !Cal.isDate(latestDay, inSameDayAs: Date()) {
         latestDay = Date()
         selectedDay = Date()
      }
   }
}

struct IntermediaryHabitListView: View {
   
   @Binding var hideTabBar: Bool
   
   var body: some View {
      let _ = Self._printChanges()
      HabitListView(hideTabBar: $hideTabBar)
   }
}


struct IntermediaryHeaderView: View {
   var body: some View {
      let _ = Self._printChanges()
      HabitsHeaderView()
   }
}

struct HabitListViewContainer: View {
   
   @Environment(\.scenePhase) var scenePhase
   @EnvironmentObject var nav: HabitTabNavPath
   @EnvironmentObject var hlvm: HabitListViewModel
   
   @StateObject var selectedDayModel = SelectedDayModel()
   
   @State private var hideTabBar = false
   
   var body: some View {
      let _ = Self._printChanges()
      Background {
         VStack {
            IntermediaryHeaderView()
            IntermediaryHabitListView(hideTabBar: $hideTabBar)
         }
         .navigationDestination(for: HabitListViewRoute.self) { route in
            if case let .showProgress(habit) = route {
               HabitProgessView()
                  .environmentObject(nav)
                  .environmentObject(habit)
            }
            if case .createHabit = route {
               CreateHabitName(hideTabBar: $hideTabBar)
                  .environmentObject(nav)
            }
         }
      }
      .environmentObject(selectedDayModel)
      .onAppear {
         selectedDayModel.updateDayToToday()
      }
   }
}

struct HabitListViewContainer_Previews: PreviewProvider {
   static var previews: some View {
      HabitListViewContainer()
   }
}
