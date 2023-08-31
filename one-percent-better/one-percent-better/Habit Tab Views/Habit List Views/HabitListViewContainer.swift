//
//  HabitListViewContainer.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 4/11/23.
//

import SwiftUI

/// The view model which controls the selected date in the habit list view
class SelectedDateViewModel: ObservableObject {

    /// The selected date
    @Published var selectedDate = Date()
    
    /// The latest day that has been shown. This is updated when the
    /// app is opened or the view appears on a new day.
    @Published var latestDay = Date()
    
    lazy var dateTitleFormatter: DateFormatter = {
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.locale = Locale.autoupdatingCurrent
        df.setLocalizedDateFormatFromTemplate("EEEE, MMM d, YYYY")
        return df
    }()
    
    var navTitle: String {
        dateTitleFormatter.string(from: selectedDate)
    }
}

struct HabitListViewContainer: View {
    
    @EnvironmentObject var barManager: BottomBarManager
    @StateObject var sdvm = SelectedDateViewModel()
    
    var body: some View {
        Background {
            VStack(spacing: 5) {
                HabitsHeaderView(sdvm: sdvm)
                HabitListView(sdvm: sdvm)
            }
            .navigationDestination(for: HabitListViewRoute.self) { route in
                switch route {
                case let .showProgress(habit):
                    HabitProgressViewContainer(habit: habit)
                case .createHabit:
                    CreateHabitName()
                }
            }
        }
        .environmentObject(sdvm)
        .navigationTitle(sdvm.navTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // New Habit
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(value: HabitListViewRoute.createHabit) {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
        .toolbarBackground(Color.backgroundColor, for: .tabBar)
        .toolbar(barManager.isHidden ? .hidden : .visible, for: .tabBar)
    }
}

//struct HabitListViewContainer_Previews: PreviewProvider {
//   static var previews: some View {
//      HabitListViewContainer()
//   }
//}
