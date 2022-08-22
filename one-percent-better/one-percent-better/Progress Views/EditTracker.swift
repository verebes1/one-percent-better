//
//  EditTracker.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 8/8/22.
//

import SwiftUI

struct EditTracker: View {
    
    var tracker: Tracker
    
    @State private var trackerName: String
    
    init(tracker: Tracker) {
        self.tracker = tracker
        self._trackerName = State(initialValue: tracker.name)
    }
    
    var body: some View {
        Background {
            VStack {
                List {
                    Section {
                        HStack {
                            Text("Name")
                                .fontWeight(.medium)
                            TextField("", text: $trackerName)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.decimalPad)
                                .frame(height: 30)
                        }
                    }
                    
                    Section {
                        Button {
                            print("Delete tracker")
                        } label: {
                            HStack {
                                Text("Delete")
                                    .foregroundColor(.red)
                                Spacer()
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                
            }
        }
    }
}

struct EditTracker_Previews: PreviewProvider {
    
    static func data() -> NumberTracker {
        let context = CoreDataManager.previews.persistentContainer.viewContext
        
        let day0 = Date()
        let day1 = Calendar.current.date(byAdding: .day, value: -1, to: day0)!
        let day2 = Calendar.current.date(byAdding: .day, value: -2, to: day0)!
        
        let h1 = try? Habit(context: context, name: "Swimming")
        h1?.markCompleted(on: day2)
        
        if let h1 = h1 {
            let t1 = NumberTracker(context: context, habit: h1, name: "Laps")
            t1.add(date: day0, value: "3")
            t1.add(date: day1, value: "2")
            t1.add(date: day2, value: "1")
        }
        
        let habits = Habit.habitList(from: context)
        return habits.first!.trackers.firstObject as! NumberTracker
    }
    
    static var previews: some View {
        let t = data()
        EditTracker(tracker: t)
    }
}
