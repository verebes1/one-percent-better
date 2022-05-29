//
//  NumberTracker.swift
//
//
//  Created by Jeremy on 4/10/21.
//
//

import Foundation
import CoreData
import UIKit

@objc(NumberTracker)
public class NumberTracker: GraphTracker {
    
    convenience init(context: NSManagedObjectContext, habit: Habit, name: String) {
        self.init(context: context)
        self.habit = habit
        self.name = name
        self.autoTracker = false
        self.dates = []
        self.values = []
    }
    
    override func toString() -> String {
        return "Number"
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
