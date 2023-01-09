//
//  FrequencySegmentSelection.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 1/9/23.
//

import SwiftUI

struct FrequencySegmentSelection: View {
   
   @State private var segmentSelection: FreqSegment = .daily
   
    var body: some View {
       Picker("", selection: $segmentSelection) {
          ForEach(FreqSegment.allCases) { freq in
             Text(freq.rawValue.capitalized)
          }
       }
       .pickerStyle(.segmented)
       .padding(10)
    }
}

struct FrequencySegmentSelection_Previews: PreviewProvider {
    static var previews: some View {
        FrequencySegmentSelection()
    }
}
