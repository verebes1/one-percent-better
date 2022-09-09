//
//  ExerciseTracker+CoreDataClass.swift
//  
//
//  Created by Jeremy Cook on 9/8/22.
//
//

import Foundation
import CoreData

@objc(ExerciseTracker)
public class ExerciseTracker: Tracker {

    @NSManaged public var dates: [Date]
    
    /// For example, if a workout looks like:
    ///
    /// Set 1       100 lbs     10 reps
    /// Set 2       105 lbs     8 reps
    /// Set 3       110 lbs     6 reps
    /// Set 4       110 lbs     6 reps
    ///
    /// Then the reps array will look like: [..., [10, 8, 6, 6]]
    /// The weights array will look like: [..., [100, 105, 110, 100]]
    
    /// How many repetitions for each set
    @NSManaged public var reps: [[Int]]
    
    /// The weight for each set
    @NSManaged public var weights: [[Double]]
    
    
    convenience init(context: NSManagedObjectContext, habit: Habit, name: String) {
        self.init(context: context)
        self.context = context
        self.habit = habit
        self.name = name
        self.autoTracker = false
        self.dates = []
        self.reps = []
        self.weights = []
    }
    
    func addSet(set: Int, rep: Int, weight: Double, on date: Date) {
        if let dateIndex = dates.firstIndex(where: {day in Calendar.current.isDate(day, inSameDayAs: date) }) {
            var repsArray = reps[dateIndex]
            var weightsArray = weights[dateIndex]
            
            let setIndex = set - 1
            if setIndex <= repsArray.count {
                repsArray[setIndex] = rep
                weightsArray[setIndex] = weight
            } else {
                repsArray.append(rep)
                weightsArray.append(weight)
            }
            reps[dateIndex] = repsArray
            weights[dateIndex] = weightsArray
        } else {
            dates.append(date)
            reps.append([rep])
            weights.append([weight])
            
            // sort both lists by dates
            let repWeights = zip(reps, weights)
            let combined = zip(dates, repWeights).sorted { $0.0 < $1.0 }
            dates = combined.map { $0.0 }
            reps = combined.map { $0.1.0 }
            weights = combined.map { $0.1.1 }
        }
        context.fatalSave()
    }
}
