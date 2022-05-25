//
//  ProgressView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/18/22.
//

import SwiftUI
import CoreData

struct ProgressView: View {
    
    @EnvironmentObject var habit: Habit
    
    var body: some View {
        Background {
            VStack {
                HStack {
                    Text(habit.name)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                    .font(.title)
                    Spacer()
                }
                .padding(.horizontal, 15)
                
                CardView {
                    CalendarView()
                }
                
                Text("Hello World")
                Spacer()
            }
        }
    }
}

struct ProgressView_Previews: PreviewProvider {
    
    static var previews: some View {
        let habit = PreviewData.progressViewData()
        return ProgressView()
            .environmentObject(habit)
    }
}
