//
//  GraphCardView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/15/22.
//

import SwiftUI

struct GraphCardView: View {
    
    enum TimeButtons: String {
        case oneWeek = "1W"
        case twoWeeks = "2W"
        case oneMonth = "1M"
        case threeMonths = "3M"
        case sixMonths = "6M"
        case oneYear = "1Y"
        
        func numDays() -> Int {
            switch self {
            case .oneWeek:
                return 7
            case .twoWeeks:
                return 14
            case .oneMonth:
                return 30
            case .threeMonths:
                return 91
            case .sixMonths:
                return 183
            case .oneYear:
                return 365
            }
        }
    }
    
    var tracker: GraphTracker
    var color: Color = .blue
    @State var selectedValue: String = ""
    @State var selectedButton: TimeButtons = .oneWeek
    var buttons: [TimeButtons] = [.oneWeek, .twoWeeks, .oneMonth, .threeMonths, .sixMonths, .oneYear]
    
    var body: some View {
        CardView {
            VStack(spacing: 0) {
                
                SimpleCardTitle(tracker.name) {
                    Text(selectedValue)
                }
                
//                HStack {
//                    CardTitle(tracker.name)
//                    Spacer()
//                }
//                .padding(.horizontal, 20)
//                .padding(.top, 5)
                
                GraphView(graphData: GraphData(graphTracker: tracker),
                          numDays: selectedButton.numDays(),
                          selectedValue: $selectedValue)
                
                HStack(spacing: 12) {
                    ForEach(0 ..< 6, id: \.self) { i in
                        ZStack {
                            let isSelected = buttons[i] == selectedButton
                            RoundedRectangle(cornerRadius: 7)
                                .foregroundColor(color)
                                .opacity(isSelected ? 1 : 0.2)
                            
                            Text(buttons[i].rawValue)
                                .fontWeight(.bold)
                                .font(.system(size: 11))
                                .foregroundColor(isSelected ? .white : color)
                        }
                        .frame(height: 30)
                        .onTapGesture {
                            selectedButton = buttons[i]
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
            }
        }
        .frame(height: 310)
    }
}

struct GraphCardView_Previews: PreviewProvider {
    
    static func data() -> GraphTracker {
        let context = CoreDataManager.previews.persistentContainer.viewContext
        
        let day0 = Date()
        let day1 = Calendar.current.date(byAdding: .day, value: -1, to: day0)!
        let day2 = Calendar.current.date(byAdding: .day, value: -2, to: day0)!
        
        let h1 = try? Habit(context: context, name: "Swimming")
        h1?.markCompleted(on: day0)
        h1?.markCompleted(on: day1)
        h1?.markCompleted(on: day2)
        
        if let h1 = h1 {
            let t1 = NumberTracker(context: context, habit: h1, name: "Laps")
            t1.add(date: day0, value: "3")
            t1.add(date: day1, value: "2")
            t1.add(date: day2, value: "1")
        }
        
        let habits = Habit.habitList(from: context)
        let habit = habits.first!
        let tracker = habit.trackers.firstObject as! GraphTracker
        return tracker
    }
    
    static var previews: some View {
        let tracker = data()
        GraphCardView(tracker: tracker)
    }
}
