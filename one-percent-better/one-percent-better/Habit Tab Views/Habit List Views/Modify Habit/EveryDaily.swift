//
//  EveryDaily.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 9/26/22.
//

import SwiftUI

struct EveryDaily: View {
    
    @Binding var timesPerDay: Int
    let tpdRange = 1 ... 100
    
    private let backgroundColor = Color(#colorLiteral(red: 0.8744927645, green: 0.9400271177, blue: 0.9856405854, alpha: 1))
    
    var body: some View {
        VStack {
            HStack {
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(backgroundColor)
                    
                    Text("\(timesPerDay)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.blue)
                }
                .frame(width: 50)
                .frame(height: 32)
                
                
                Text("time\(timesPerDay == 1 ? " " : "s ")a day")
                Spacer()
                
                MyStepper(value: $timesPerDay, range: 1 ... 100)
                
            }
        }
        .padding()
    }
}

struct EveryDailyPreviewContainer: View {
    
    @State private var timesPerDay = 1
    
    var body: some View {
        EveryDaily(timesPerDay: $timesPerDay)
    }
}

struct EveryDaily_Previews: PreviewProvider {
    
    static var previews: some View {
        EveryDailyPreviewContainer()
    }
}
