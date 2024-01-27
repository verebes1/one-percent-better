//
//  ScheduledNotification.swift
//
//
//  Created by Jeremy Cook on 3/15/23.
//
//

import Foundation
import CoreData

@objc(ScheduledNotification)
public class ScheduledNotification: NSManagedObject, Codable {
    @NSManaged public var index: Int
    @NSManaged public var date: Date
    @NSManaged public var string: String
    @NSManaged public var notification: Notification
    @NSManaged public var isScheduled: Bool
    
    convenience init(context: NSManagedObjectContext, index: Int, date: Date, string: String, notification: Notification) {
        self.init(context: context)
        self.index = index
        self.date = date
        self.string = string
        self.notification = notification
        self.isScheduled = true
    }
    
    var identifier: String {
        "OnePercentBetter&\(notification.id.uuidString)&\(index)"
    }
    
    // MARK: - Encodable
    enum CodingKeys: CodingKey {
        case index
        case date
        case string
        case notification
        case isScheduled
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw DecoderConfigurationError.missingManagedObjectContext
        }
        
        self.init(context: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.index = try container.decode(Int.self, forKey: .index)
        self.date = try container.decode(Date.self, forKey: .date)
        self.string = try container.decode(String.self, forKey: .string)
        self.notification = try container.decode(Notification.self, forKey: .notification)
        self.isScheduled = try container.decode(Bool.self, forKey: .isScheduled)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(index, forKey: .index)
        try container.encode(date, forKey: .date)
        try container.encode(string, forKey: .string)
        try container.encode(notification, forKey: .notification)
        try container.encode(isScheduled, forKey: .isScheduled)
    }
}

extension ScheduledNotification: HasFetchRequest {
    static func fetchRequest<ScheduledNotification>() -> NSFetchRequest<ScheduledNotification> {
        return NSFetchRequest<ScheduledNotification>(entityName: "ScheduledNotification")
    }
}
