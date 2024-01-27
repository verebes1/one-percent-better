//
//  XTimesPerDayFrequency+CoreDataClass.swift
//
//
//  Created by Jeremy Cook on 6/9/23.
//
//

import Foundation
import CoreData

@objc(XTimesPerDayFrequency)
public class XTimesPerDayFrequency: Frequency {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<XTimesPerDayFrequency> {
        return NSFetchRequest<XTimesPerDayFrequency>(entityName: "XTimesPerDayFrequency")
    }
    
    @NSManaged public var timesPerDay: Int
    
    convenience init(context: NSManagedObjectContext,
                     timesPerDay: Int) {
        self.init(context: context)
        self.timesPerDay = timesPerDay
    }
    
    // MARK: - Encodable
    enum CodingKeys: CodingKey {
        case startDate
        case timesPerDay
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw DecoderConfigurationError.missingManagedObjectContext
        }
        
        self.init(context: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let startDate = try container.decode(Date.self, forKey: .startDate)
        self.updateStartDate(to: startDate)
        self.timesPerDay = try container.decode(Int.self, forKey: .timesPerDay)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(timesPerDay, forKey: .timesPerDay)
    }
}
