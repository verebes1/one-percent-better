//
//  SpecificTimeNotification+CoreDataClass.swift
//
//
//  Created by Jeremy Cook on 3/5/23.
//
//

import Foundation
import CoreData

@objc(SpecificTimeNotification)
public class SpecificTimeNotification: Notification {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SpecificTimeNotification> {
        return NSFetchRequest<SpecificTimeNotification>(entityName: "SpecificTimeNotification")
    }
    
    @NSManaged public var time: Date
    
    convenience init(context: NSManagedObjectContext,
                     time: Date = Date()) {
        self.init(context: context)
        moc = context
        id = UUID()
        unscheduledNotificationStrings = []
        self.time = time
    }
    
    override func nextDue() -> Date {
        if let last = scheduledNotificationsArray.last {
            // TODO: 1.1.0 Add frequency stuff in here eventually
            let next = Cal.add(days: 1, to: last.date)
            return next
        } else {
            let time = Cal.dateComponents([.hour, .minute], from: time)
            let newDate = Cal.date(time: time, dayMonthYear: Date())
            return newDate
        }
    }
    
    // MARK: - Encodable
    enum CodingKeys: CodingKey {
        case id
        case time
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw DecoderConfigurationError.missingManagedObjectContext
        }
        
        self.init(context: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.time = try container.decode(Date.self, forKey: .time)
        
        // TODO: Export/Import notifications to not have to make API calls again all at once
        self.unscheduledNotificationStrings = []
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(time, forKey: .time)
    }
}
