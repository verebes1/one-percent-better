//
//  ImageTracker+CoreDataClass.swift
//  
//
//  Created by Jeremy on 4/10/21.
//
//

import Foundation
import CoreData
import UIKit

@objc(ImageTracker)
public class ImageTracker: Tracker {
    
    @NSManaged public var dates: [Date]
    @NSManaged public var values: [Data]
    
    convenience init(context: NSManagedObjectContext, habit: Habit, name: String) {
        self.init(context: context)
        self.habit = habit
        self.name = name
        self.autoTracker = false
        self.dates = []
        self.values = []
    }
    
    override func toString() -> String {
        return "Image"
    }
    
    func add(date: Date, value: UIImage) {
        guard let imageData = value.png() else {
            return
        }
        add(dates: &dates, values: &values, date: date, value: imageData)
    }
    
    override func remove(on date: Date) {
        remove(dates: &dates, values: &values, date: date)
    }
    
    func getValue(date: Date) -> UIImage? {
        guard let data = getValue(dates: &dates, values: &values, date: date) else {
            return nil
        }
        guard let image = UIImage(data: data) else {
            return nil
        }
        return image
    }
    
    // MARK: - Encodable
    
    enum CodingKeys: CodingKey {
        case name
        case autoTracker
        case index
        case dates
        // FIXME: import/export images correctly!
//        case values
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
        
        // FIXME: import images correctly!
        self.values = []
//        self.values = try container.decode([Data].self, forKey: .values)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(autoTracker, forKey: .autoTracker)
        try container.encode(index, forKey: .index)
        try container.encode(dates, forKey: .dates)
        
        // FIXME: export images correctly!
//        try container.encode(values, forKey: .values)
    }
}
