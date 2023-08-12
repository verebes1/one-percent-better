//
//  NoHabitsListView.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 7/28/23.
//

import SwiftUI

struct NoHabitsListView: View {
    
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        HStack(spacing: 0) {
            Text("To create a habit, press ")
                .foregroundColor(scheme == .light ? Color(hue: 1.0, saturation: 0.008, brightness: 0.279) : .secondaryLabel)
            NavigationLink(value: HabitListViewRoute.createHabit) {
                Image(systemName: "square.and.pencil")
            }
        }
        .padding(.top, 40)
    }
}

struct NoHabitsListView_Previews: PreviewProvider {
    static var previews: some View {
        NoHabitsListView()
    }
}
