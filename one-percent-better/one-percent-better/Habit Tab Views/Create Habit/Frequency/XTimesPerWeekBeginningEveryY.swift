//
//  XTimesPerWeekBeginningEveryY.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 12/30/22.
//

import SwiftUI

struct XTimesPerWeekBeginningEveryY: View {
    
    @Binding var timesPerWeek: Int
    @Binding var beginningDay: Weekday
    @EnvironmentObject var sowm: StartOfWeekModel
    var color: Color = Style.accentColor
    
    var body: some View {
        VStack {
            HStack(spacing: 7) {
                Menu {
                    ForEach(1 ..< 8) { i in
                        MenuItemWithCheckmark(value: i,
                                              selection: $timesPerWeek)
                    }
                } label: {
                    CapsuleMenuButton(text: String(timesPerWeek),
                                      color: color,
                                      fontSize: 15)
                }
                
                HStack(spacing: 0) {
                    AnimatedPlural(text: "time", value: timesPerWeek)
                    Text(" per week")
                }
            }
            .animation(.easeInOut, value: timesPerWeek)
            
            HStack(spacing: 7) {
                Text("beginning every")
                Menu {
                    ForEach(Weekday.orderedCases) { weekday in
                        MenuItemWithCheckmark(value: weekday,
                                              selection: $beginningDay)
                    }
                } label: {
                    CapsuleMenuButton(text: "\(beginningDay)",
                                      color: color,
                                      fontSize: 15)
                }
            }
            .animation(.easeInOut, value: beginningDay)
            .onChange(of: sowm.startOfWeek) { newStartOfWeek in
                beginningDay = newStartOfWeek
            }
        }
        .padding(10)
    }
}

struct XTimesPerWeekBeginningEveryYPreviewer: View {
    
    @State private var timesPerWeek = 1
    @State private var beginningDay: Weekday = .sunday
    
    var body: some View {
        Background {
            XTimesPerWeekBeginningEveryY(timesPerWeek: $timesPerWeek, beginningDay: $beginningDay)
        }
    }
}

struct XTimesPerWeekBeginningEveryY_Previews: PreviewProvider {
    static var previews: some View {
        XTimesPerWeekBeginningEveryYPreviewer()
    }
}
