//
//  FeatureLog+CoreDataClass.swift
//  
//
//  Created by Jeremy Cook on 8/25/22.
//
//

import Foundation
import CoreData

@objc(FeatureLog)
public class FeatureLog: NSManagedObject, Codable {
   
   @NSManaged public var hasTimesCompleted: Bool
   @NSManaged public var hasNotificationTimeAsDate: Bool
   @NSManaged public var hasTrackerIndices: Bool
   @NSManaged public var hasTrackerToHabitRelationship: Bool
   @NSManaged public var hasImprovement: Bool
   
   /// Starting with 1.0.3, habit frequency is an array and must be paired with a frequency date array
   /// to know when the user changed the frequency
   @NSManaged public var hasFrequencyDates: Bool
   
   /// v1.0.4: Each habit now has a unique ID
   @NSManaged public var hasID: Bool
   
   // MARK: - Encodable
   
   enum CodingKeys: CodingKey {
      case hasTimesCompleted
      case hasNotificationTimeAsDate
      case hasTrackerIndices
      case hasTrackerToHabitRelationship
      case hasImprovement
      case hasFrequencyDates
      case hasID
   }
   
   required convenience public init(from decoder: Decoder) throws {
      guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
         throw DecoderConfigurationError.missingManagedObjectContext
      }
      
      let container = try decoder.container(keyedBy: CodingKeys.self)
      
      // Delete current feature log
      if let log = FeatureLog.getFeatureLog(from: context) {
         context.delete(log)
      }
      
      self.init(context: context)
      self.hasTimesCompleted = try container.decode(Bool.self, forKey: .hasTimesCompleted)
      self.hasNotificationTimeAsDate = try container.decode(Bool.self, forKey: .hasNotificationTimeAsDate)
      self.hasTrackerIndices = try container.decode(Bool.self, forKey: .hasTrackerIndices)
      self.hasTrackerToHabitRelationship = try container.decode(Bool.self, forKey: .hasTrackerToHabitRelationship)
      self.hasImprovement = try container.decode(Bool.self, forKey: .hasImprovement)
      self.hasFrequencyDates = try container.decode(Bool.self, forKey: .hasFrequencyDates)
      self.hasID = try container.decode(Bool.self, forKey: .hasID)
   }
   
   public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(hasTimesCompleted, forKey: .hasTimesCompleted)
      try container.encode(hasNotificationTimeAsDate, forKey: .hasNotificationTimeAsDate)
      try container.encode(hasTrackerIndices, forKey: .hasTrackerIndices)
      try container.encode(hasTrackerToHabitRelationship, forKey: .hasTrackerToHabitRelationship)
      try container.encode(hasImprovement, forKey: .hasImprovement)
      try container.encode(hasFrequencyDates, forKey: .hasFrequencyDates)
      try container.encode(hasID, forKey: .hasID)
   }
   
   // MARK: Fetch Request
   
   @nonobjc public class func fetchRequest() -> NSFetchRequest<FeatureLog> {
      return NSFetchRequest<FeatureLog>(entityName: "FeatureLog")
   }
   
   class func getFeatureLog(from context: NSManagedObjectContext) -> FeatureLog? {
      var featureLogs: [FeatureLog] = []
      do {
         // fetch all habits
         let fetchRequest: NSFetchRequest<FeatureLog> = FeatureLog.fetchRequest()
         featureLogs = try context.fetch(fetchRequest)
      } catch {
         fatalError("FeatureLog.swift \(#function) - unable to fetch featureLog! Error: \(error)")
      }
      
      guard !featureLogs.isEmpty else {
         fatalError("No feature log!")
      }
      
      guard featureLogs.count == 1 else {
         fatalError("Too many feature logs! Count: \(featureLogs.count)")
      }
      
      return featureLogs[0]
   }
}
