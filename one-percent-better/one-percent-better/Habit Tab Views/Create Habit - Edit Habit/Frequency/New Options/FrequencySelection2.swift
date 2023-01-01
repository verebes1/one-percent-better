//
//  FrequencySelection2.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 12/30/22.
//

import SwiftUI

struct FrequencySelection2: View {
   
   @State private var segmentSelection: FreqSegment = .daily
   
   var body: some View {
      Background {
         VStack {
            Picker("", selection: $segmentSelection) {
               ForEach(FreqSegment.allCases) { freq in
                  Text(freq.rawValue.capitalized)
               }
            }
            .pickerStyle(.segmented)
            .padding(10)
            
            EveryDaily2()
            
            EveryWeekly2()
            
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
