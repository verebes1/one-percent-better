//
//  ImageCardView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/15/22.
//

import SwiftUI

struct ImageCardView: View {
    
    var imageTracker: ImageTracker
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 5)
    
    var body: some View {
        CardView {
            VStack {
                SimpleCardTitle(imageTracker.name) {
                    Button("View All") {
                        print("test")
                    }
                }
                
                LazyVGrid(columns: columns) {
                    ForEach(0 ..< imageTracker.values.count, id: \.self) { i in
                        if let image = imageTracker.getValue(date: imageTracker.dates[i]) {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 50, height: 50)
                        }
                    }
                }
            }
        }
        
    }
}

struct ImageCardView_Previews: PreviewProvider {
    
    static func data() -> ImageTracker {
        let context = CoreDataManager.previews.persistentContainer.viewContext
        
        let day0 = Date()
        let day1 = Calendar.current.date(byAdding: .day, value: -1, to: day0)!
        let day2 = Calendar.current.date(byAdding: .day, value: -2, to: day0)!
        
        let h1 = try? Habit(context: context, name: "Swimming")
        h1?.markCompleted(on: day0)
        h1?.markCompleted(on: day1)
        h1?.markCompleted(on: day2)
        
        if let h1 = h1 {
            let t1 = ImageTracker(context: context, habit: h1, name: "Laps")
            
            let patioBefore = UIImage(named: "patio-before")!
            var day = day1
            for _ in 0 ..< 7 {
                t1.add(date: day, value: patioBefore)
                day = Calendar.current.date(byAdding: .day, value: -1, to: day)!
            }
            t1.add(date: day0, value: UIImage(named: "patio-done")!)
        }
        
        let habits = Habit.habitList(from: context)
        let habit = habits.first!
        let tracker = habit.trackers.firstObject as! ImageTracker
        return tracker
    }
    
    static var previews: some View {
        let imageTracker = data()
        Background {
            ImageCardView(imageTracker: imageTracker)
        }
    }
}
