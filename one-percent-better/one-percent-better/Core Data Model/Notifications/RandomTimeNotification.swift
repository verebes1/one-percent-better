//
//  RandomTimeNotification+CoreDataClass.swift
//  
//
//  Created by Jeremy Cook on 3/5/23.
//
//

import Foundation
import CoreData

@objc(RandomTimeNotification)
public class RandomTimeNotification: Notification {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<RandomTimeNotification> {
        return NSFetchRequest<RandomTimeNotification>(entityName: "RandomTimeNotification")
    }
    
    @NSManaged public var startTime: Date
    @NSManaged public var endTime: Date
    
    lazy var startTimeDefault: Date = {
        var components = DateComponents()
        components.hour = 9
        components.minute = 0
        return Cal.date(from: components) ?? Date()
    }()
    
    lazy var endTimeDefault: Date = {
        var components = DateComponents()
        components.hour = 17
        components.minute = 0
        return Cal.date(from: components) ?? Date()
    }()
    
    convenience init(myContext: NSManagedObjectContext, openAIDelegate: ChatGPTDelegate = OpenAIManager.shared, startTime: Date? = nil, endTime: Date? = nil) {
        self.init(context: myContext)
        super.moc = myContext
        self.id = UUID()
        self.unscheduledNotificationStrings = []
        self.startTime = startTime ?? startTimeDefault
        self.endTime = endTime ?? endTimeDefault
    }
    
    override func nextDue() -> Date {
        if let last = scheduledNotificationsArray.last {
            let next = Cal.add(days: 1, to: last.date)
            return next
        } else {
            let time = Cal.dateComponents([.hour, .minute], from: startTime)
            let newDate = Cal.date(time: time, dayMonthYear: Date())
            return newDate
        }
    }
    
    func getRandomTime() -> DateComponents {
        let startTime = Cal.dateComponents([.hour, .minute], from: self.startTime)
        let endTime = Cal.dateComponents([.hour, .minute], from: self.endTime)
        
        guard let startHour = startTime.hour,
              let startMinute = startTime.minute,
              let endHour = endTime.hour,
              let endMinute = endTime.minute else {
            fatalError("Unable to get hour and minutes for random notification")
        }
        
        var startMinutes = startHour * 60 + startMinute
        var endMinutes = endHour * 60 + endMinute
        
        // TODO: 1.1.4 fix this properly by not allowing it when saving and showing an error
        if startMinutes >= endMinutes {
            let temp = startMinutes
            startMinutes = endMinutes
            endMinutes = temp
        }
        
        let randomTime = Int.random(in: startMinutes ... endMinutes)
        let randomHour = randomTime / 60
        let randomMinute = randomTime % 60
        
        var components = DateComponents()
        components.hour = randomHour
        components.minute = randomMinute
        return components
    }
    
    // MARK: - Encodable
    enum CodingKeys: CodingKey {
        case id
        case startTime
        case endTime
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw DecoderConfigurationError.missingManagedObjectContext
        }
        
        self.init(context: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.startTime = try container.decode(Date.self, forKey: .startTime)
        self.endTime = try container.decode(Date.self, forKey: .endTime)
        
        // TODO: Export/Import notifications to not have to make API calls again all at once
        self.unscheduledNotificationStrings = []
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(endTime, forKey: .endTime)
    }
}
