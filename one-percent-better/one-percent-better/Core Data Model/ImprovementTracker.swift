//
//  ImprovementTracker.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 1/23/22.
//

import Foundation
import CoreData

@objc(ImprovementTracker)
public class ImprovementTracker: GraphTracker {
    
    /// Default initializer for improvement tracker
    /// - Parameters:
    ///   - context: The managed object context
    ///   - nothing: Argument to differentiate this initializer from self.init(context: context)
    convenience init(context: NSManagedObjectContext, habit: Habit) {
        self.init(context: context)
        self.habit = habit
        self.name = "Improvement"
        self.autoTracker = true
        self.dates = []
        self.values = []
    }
    
    override func toString() -> String {
        return "Improvement"
    }
    
    func updateImprovementTracker(habit: Habit) {
        // TODO: Make this more efficient by adding dirty bit to Habit, so that whenever something changes, we know to update this tracker
        self.reset()
        createData(habit: habit)
        CoreDataManager.shared.saveContext()
    }
    
    func update() {
        self.reset()
        createData(habit: habit)
        CoreDataManager.shared.saveContext()
    }
    
    func reset() {
        self.dates = []
        self.values = []
    }
    
    func createData(habit: Habit) {
        var score: Double = 100
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        var curDate = habit.startDate
        while !Calendar.current.isDate(curDate, inSameDayAs: tomorrow) {
            if habit.wasCompleted(on: curDate) {
                score *= 1.01
            } else {
                score *= 0.995
                
                if score < 100 {
                    score = 100
                }
            }
            let roundedScore = round(score)
            self.add(date: curDate, value: String(Int(roundedScore)))
            curDate = Calendar.current.date(byAdding: .day, value: 1, to: curDate)!
        }
    }
    
    // MARK: - Encodable
    enum CodingKeys: CodingKey {
        case name
        case autoTracker
        case index
        case dates
        case values
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
        self.values = try container.decode([String].self, forKey: .values)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(autoTracker, forKey: .autoTracker)
        try container.encode(index, forKey: .index)
        try container.encode(dates, forKey: .dates)
        try container.encode(values, forKey: .values)
    }
    
}

extension ImprovementTracker {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImprovementTracker> {
        return NSFetchRequest<ImprovementTracker>(entityName: "ImprovementTracker")
    }
}
