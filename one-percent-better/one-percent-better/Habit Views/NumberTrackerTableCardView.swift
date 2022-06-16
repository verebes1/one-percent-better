//
//  NumberTrackerTableCardView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/8/22.
//

import SwiftUI


struct NumberTrackerTableCardView: View {
    
    var tracker: Tracker
    
    var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.setLocalizedDateFormatFromTemplate("MMM d, YYYY")
        return dateFormatter
    }()
    
    var body: some View {
        CardView {
            VStack(spacing: 5) {
                
                HStack {
                    Text(tracker.name)
                        .font(.title2)
                        .fontWeight(.medium)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 5)
                
                ScrollView {
                    if let t = tracker as? NumberTracker {
                        ForEach(t.dates, id: \.self) { date in
                            HStack {
                                Text(dateFormatter.string(from: date))
                                Spacer()
                                Text(t.getValue(date: date)!)
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
            }
        }
        .frame(maxHeight: 200)
    }
}

struct NumberTrackerTableCardView_Previews: PreviewProvider {
    
    static func data() -> Tracker {
        let context = CoreDataManager.previews.persistentContainer.viewContext
        
        
        
        let h1 = try? Habit(context: context, name: "Swimming")
        
        if let h1 = h1 {
            let t1 = NumberTracker(context: context, habit: h1, name: "Laps")
            var day = Date()
            for i in 0 ..< 100 {
                t1.add(date: day, value: "\(i)")
                day = Calendar.current.date(byAdding: .day, value: -1, to: day)!
            }
        }
        
        let habits = Habit.habitList(from: context)
        return habits.first!.trackers.firstObject! as! Tracker
    }
    
    static var previews: some View {
        let tracker = data()
        Background {
            NumberTrackerTableCardView(tracker: tracker)
        }
    }
}
