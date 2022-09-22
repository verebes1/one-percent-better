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
    @NSManaged public var weights: [[String]]
    
    
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
    
    func addSet(set: Int, rep: Int, weight: String, on date: Date) {
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
    
    func updateSets(sets: [WeightRep], on date: Date = Date()) {
        
        var newReps: [Int] = []
        var newWeights: [String] = []
        for s in sets {
            if let rep = s.rep {
                newReps.append(rep)
            }
            if let weight = s.weight {
                newWeights.append(weight)
            }
        }
        
        if let dateIndex = dates.firstIndex(where: {day in Calendar.current.isDate(day, inSameDayAs: date) }) {
            reps[dateIndex] = newReps
            weights[dateIndex] = newWeights
        } else {
            dates.append(date)
            reps.append(newReps)
            weights.append(newWeights)
            
            // sort both lists by dates
            let repWeights = zip(reps, weights)
            let combined = zip(dates, repWeights).sorted { $0.0 < $1.0 }
            dates = combined.map { $0.0 }
            reps = combined.map { $0.1.0 }
            weights = combined.map { $0.1.1 }
        }
        context.fatalSave()
    }
    
    func getEntry(on date: Date) -> ExerciseEntryModel? {
        if let dateIndex = dates.firstIndex(where: {day in Calendar.current.isDate(day, inSameDayAs: date) }) {
            return ExerciseEntryModel(reps: reps[dateIndex], weights: weights[dateIndex])
        } else {
            return nil
        }
    }
    
    func getPreviousEntry(before date: Date) -> ExerciseEntryModel? {
        if let dateIndex = dates.lastIndex(where: {day in day < date && !Calendar.current.isDate(day, inSameDayAs: date) }) {
            return ExerciseEntryModel(reps: reps[dateIndex], weights: weights[dateIndex])
        } else {
            return nil
        }
    }
    
    func getAllEntries() -> [ExerciseEntryModel] {
        var result = [ExerciseEntryModel]()
        for i in 0 ..< dates.count {
            result.append(ExerciseEntryModel(reps: reps[i], weights: weights[i]))
        }
        return result
    }
    
    override func remove(on date: Date) {
        if let dateIndex = dates.firstIndex(where: {day in Calendar.current.isDate(day, inSameDayAs: date) }) {
            reps.remove(at: dateIndex)
            weights.remove(at: dateIndex)
            dates.remove(at: dateIndex)
        }
    }
}
