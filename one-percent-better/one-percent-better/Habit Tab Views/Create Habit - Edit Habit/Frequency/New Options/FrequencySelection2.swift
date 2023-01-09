//
//  FrequencySelection2.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 12/30/22.
//

import SwiftUI

struct FrequencySelection2: View {
   
   @Environment(\.colorScheme) var scheme
   
   @State private var freqSelection: HabitFrequency = .timesPerDay(1)
   
   let segmentBgColor: Color = Color( #colorLiteral(red: 0.8901956677, green: 0.8901965022, blue: 0.9074040651, alpha: 1) )
   
   var body: some View {
      Background {
         VStack(spacing: 0) {

            HStack {
               Text("Daily")
                  .foregroundColor(.secondaryLabel)
                  .padding(.leading, 60)
               Spacer()
            }
            .padding(.bottom, 10)
            SelectableCard2Wrapper(selection: $freqSelection, type: .timesPerDay(1)) {
               EveryDaily2()
            }
            .padding(.bottom, 20)
            
            HStack {
               Text("Weekly")
                  .foregroundColor(.secondaryLabel)
                  .padding(.leading, 60)
               Spacer()
            }
            .padding(.bottom, 10)
            SelectableCard2Wrapper(selection: $freqSelection, type: .daysInTheWeek([1,2,3])) {
               EveryWeekly2()
            }
            
            Spacer()
         }
      }
   }
}

struct FrequencySelection2_Previews: PreviewProvider {
   static var previews: some View {
      FrequencySelection2()
   }
}
