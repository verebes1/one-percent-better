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
        if let dateIndex = dates.firstIndex(where: {day in Cal.isDate(day, inSameDayAs: date) }) {
            var repsArray = reps[dateIndex]
            var weightsArray = weights[dateIndex]
            
            let setIndex = set - 1
            if setIndex < repsArray.count {
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
        
        if let dateIndex = dates.firstIndex(where: {day in Cal.isDate(day, inSameDayAs: date) }) {
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
        if let dateIndex = dates.firstIndex(where: {day in Cal.isDate(day, inSameDayAs: date) }) {
            return ExerciseEntryModel(reps: reps[dateIndex], weights: weights[dateIndex])
        } else {
            return nil
        }
    }
    
    func getPreviousEntry(before date: Date, allowSameDay: Bool = false) -> ExerciseEntryModel? {
        if let dateIndex = dates.lastIndex(where: {day in day < date && (allowSameDay || !Cal.isDate(day, inSameDayAs: date)) }) {
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
        return result.reversed()
    }
    
    override func remove(on date: Date) {
        if let dateIndex = dates.firstIndex(where: {day in Cal.isDate(day, inSameDayAs: date) }) {
            reps.remove(at: dateIndex)
            weights.remove(at: dateIndex)
            dates.remove(at: dateIndex)
        }
    }
    
    // MARK: - Encodable
    enum CodingKeys: CodingKey {
        case name
        case autoTracker
        case index
        case dates
        case reps
        case weights
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw DecoderConfigurationError.missingManagedObjectContext
        }
        
        self.init(context: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.autoTracker = try container.decode(Bool.self, forKey: .autoTracker)
        self.index = try container.decode(Int.self, forKey: .index)
        self.dates = try container.decode([Date].self, forKey: .dates)
        self.reps = try container.decode([[Int]].self, forKey: .reps)
        self.weights = try container.decode([[String]].self, forKey: .weights)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(autoTracker, forKey: .autoTracker)
        try container.encode(index, forKey: .index)
        try container.encode(dates, forKey: .dates)
        try container.encode(reps, forKey: .reps)
        try container.encode(weights, forKey: .weights)
    }
}
