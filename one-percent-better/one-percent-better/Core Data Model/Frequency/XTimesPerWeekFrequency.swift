//
//  XTimesPerWeekFrequency+CoreDataClass.swift
//
//
//  Created by Jeremy Cook on 6/9/23.
//
//

import Foundation
import CoreData

@objc(XTimesPerWeekFrequency)
public class XTimesPerWeekFrequency: Frequency {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<XTimesPerWeekFrequency> {
        return NSFetchRequest<XTimesPerWeekFrequency>(entityName: "XTimesPerWeekFrequency")
    }
    
    @NSManaged public var timesPerWeek: Int
    @NSManaged public var resetDay: Int
    
    convenience init(context: NSManagedObjectContext,
                     timesPerWeek: Int,
                     resetDay: Weekday = .sunday) {
        self.init(context: context)
        self.timesPerWeek = timesPerWeek
        self.resetDay = resetDay.rawValue
    }
    
    // MARK: - Encodable
    enum CodingKeys: CodingKey {
        case startDate
        case timesPerWeek
        case resetDay
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw DecoderConfigurationError.missingManagedObjectContext
        }
        
        self.init(context: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let startDate = try container.decode(Date.self, forKey: .startDate)
        self.updateStartDate(to: startDate)
        self.timesPerWeek = try container.decode(Int.self, forKey: .timesPerWeek)
        self.resetDay = try container.decode(Int.self, forKey: .resetDay)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(timesPerWeek, forKey: .timesPerWeek)
        try container.encode(resetDay, forKey: .resetDay)
    }
}
