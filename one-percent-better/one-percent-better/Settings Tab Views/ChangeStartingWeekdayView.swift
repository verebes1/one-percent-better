//
//  ChangeStartingWeekdayView.swift
//  
//
//  Created by Jeremy Cook on 8/22/23.
//

import SwiftUI

struct ChangeStartingWeekdayView: View {
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var settings: Settings
    
    @State private var selectedWeekdayMenu: Weekday = .monday
    
    var body: some View {
        HStack {
            // Maybe a whole view with an animated sun/moon which show and hide
            IconTextRow(title: "Start of Week", icon: "calendar", color: .systemOrange)
            Spacer()
            
            Menu {
                MenuItemWithCheckmark(value: Weekday.friday, selection: $selectedWeekdayMenu)
                MenuItemWithCheckmark(value: Weekday.saturday, selection: $selectedWeekdayMenu)
                MenuItemWithCheckmark(value: Weekday.sunday, selection: $selectedWeekdayMenu)
                MenuItemWithCheckmark(value: Weekday.monday, selection: $selectedWeekdayMenu)
            } label: {
                HStack {
                    Text(String(describing: selectedWeekdayMenu))
                    Image(systemName: "chevron.down")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 6)
                }
                .fixedSize()
            }
            .onChange(of: selectedWeekdayMenu) { newValue in
                settings.startingWeekdayInt = newValue.rawValue
                moc.assertSave()
            }
        }
        .onAppear {
            selectedWeekdayMenu = settings.startOfWeek
        }
    }
}

struct ChangeStartingWeekdayView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = CoreDataManager.previews.mainContext
        let settings = Settings(myContext: moc)
        ChangeStartingWeekdayView()
            .environmentObject(settings)
    }
}
