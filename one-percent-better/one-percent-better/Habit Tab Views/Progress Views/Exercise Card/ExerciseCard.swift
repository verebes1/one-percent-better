//
//  ExerciseCard.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 9/22/22.
//

import SwiftUI

struct ExerciseCard: View {
    var tracker: ExerciseTracker
    
    var vm: ExerciseEntryModel?
    
    let columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: 3)
    
    var viewAllButton: Bool = true
    
    var date: Date = Date()
    
    var dateTitleFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.setLocalizedDateFormatFromTemplate("MMM d, YYYY")
        return dateFormatter
    }()
    
    var body: some View {
        VStack {
            HStack {
                Text(tracker.name)
                    .fontWeight(.medium)
                    .padding(.leading, 20)
                Spacer()
                
                if viewAllButton {
                    NavigationLink {
                        ExerciseAllEntries(tracker: tracker, entries: tracker.getAllEntries())
                    } label: {
                        HStack {
                            Text("View All")
                            Image(systemName: "chevron.right")
                        }
                        .padding(.trailing, 20)
                    }
                } else {
                    Text(dateTitleFormatter.string(from: date))
                        .padding(.trailing, 20)
                }
            }
            
            LazyVGrid(columns: columns) {
                Text("Set")
                Text("lbs")
                Text("Reps")
            }
            
            if let vm = vm {
                ForEach(Array(vm.sets.enumerated()), id: \.offset) { (i, gymSet) in
                    ExerciseCardRow(i: i, gymSet: gymSet)
                }
            } else {
                Text("No data yet")
            }
        }
        .padding(.vertical, 10)
    }
}

struct ExerciseCardRow: View {
    
    let columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: 3)
    
    let i: Int
    @ObservedObject var gymSet: WeightRep
    
    var body: some View {
        LazyVGrid(columns: columns) {
            Text(String(i+1))
                .fontWeight(.medium)
            Text(gymSet.weightField)
            Text("\(gymSet.repField)")
        }
    }
}

struct ExerciseCard_Previews: PreviewProvider {
    
    static func data() -> ExerciseTracker {
        let context = CoreDataManager.previews.mainContext
        
        let h = try? Habit(context: context, name: "Work Out")
        
        if let h = h {
            let _ = ExerciseTracker(context: context, habit: h, name: "Bench Press")
        }
        
        let habits = Habit.habits(from: context)
        return (habits.first!.trackers.firstObject as! ExerciseTracker)
    }
    
    static var previews: some View {
        let tracker = data()
        let vm = ExerciseEntryModel(reps: [8, 10, 12], weights: ["225", "245", "250"])
        Group {
            NavigationView {
                Background {
                    CardView {
                        ExerciseCard(tracker: tracker, vm: vm)
                        //                        .environmentObject(tracker)
                    }
                }
            }
        }
    }
}
