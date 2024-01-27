//
//  SpecificWeekdaysFrequency+CoreDataClass.swift
//
//
//  Created by Jeremy Cook on 6/9/23.
//
//

import Foundation
import CoreData

@objc(SpecificWeekdaysFrequency)
public class SpecificWeekdaysFrequency: Frequency {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SpecificWeekdaysFrequency> {
        return NSFetchRequest<SpecificWeekdaysFrequency>(entityName: "SpecificWeekdaysFrequency")
    }
    
    @NSManaged public var weekdays: [Int]
    
    convenience init(context: NSManagedObjectContext,
                     weekdays: Set<Weekday>) {
        self.init(context: context)
        self.weekdays = weekdays.map { $0.rawValue }
    }
    
    // MARK: - Encodable
    enum CodingKeys: CodingKey {
        case startDate
        case weekdays
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw DecoderConfigurationError.missingManagedObjectContext
        }
        
        self.init(context: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let startDate = try container.decode(Date.self, forKey: .startDate)
        self.updateStartDate(to: startDate)
        self.weekdays = try container.decode([Int].self, forKey: .weekdays)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(weekdays, forKey: .weekdays)
    }
}
