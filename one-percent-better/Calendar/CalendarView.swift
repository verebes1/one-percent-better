//
//  CalendarView.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 4/27/22.
//

import SwiftUI

struct CalendarView: View {
    
    /// Object used to calculate an array of days for each month
    var calendarCalculator = CalendarCalculator()
    
    var body: some View {
        
        let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 7)
        let columnSpacing: CGFloat = 11
        
        let smwttfs = ["S", "M", "T", "W", "T", "F", "S"]
    
        VStack {
            HStack(spacing: 0) {
                Spacer(minLength: 15)
                
                Text("April 2022")
                .font(.title)
                
                Spacer()
                
                Text("23 days of 30 so far")
                    .font(.system(size: 15))
                    .foregroundColor(Color(hue: 1.0, saturation: 0.009, brightness: 0.239))
                    
                
                RingView(percent: 0.5,
                         size: 20)
                    .frame(width: 30, height: 30)
                
                Spacer(minLength: 15)
            }
                
            LazyVGrid(columns: columns, spacing: columnSpacing) {
                ForEach(0..<7) { i in
                    Text(smwttfs[i])
                        .fontWeight(.regular)
                        .foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.393))
                        
                }
            }
            
            LazyVGrid(columns: columns, spacing: columnSpacing) {
                ForEach(calendarCalculator.days, id: \.date) { day in
                    CardView(title: day.dayNumber,      width: 30,
                             height: 30,
                             isFilled: day.isWithinDisplayedMonth)
                        .frame(height: 50)
                }
            }
        }
    }
}


struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
            
    }
}


struct CardView: View {
    let title: String
    var width: CGFloat? = nil
    var height: CGFloat? = nil
    var isFilled: Bool = false
    
    var body: some View {
        VStack (spacing: 3) {
            
            Text(title)
                .font(.body)
            
            if isFilled {
                Circle()
                    .foregroundColor(.green)
                    .frame(width: width, height: height)
            } else {
                Circle()
                    .stroke(.gray, style: .init(lineWidth: 1))
                    .frame(width: width, height: height)
            }
            
//            RoundedRectangle(cornerRadius: 14)
//                .foregroundColor(.random)
//                .frame(width: width, height: height)

        }
        
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(title: "23", width: 30, height: 30)
//        CardView(title: "23", width: 40, height: 40)
    }
}


extension String: Identifiable {
    public typealias ID = Int
    public var id: Int {
        return hash
    }
}
