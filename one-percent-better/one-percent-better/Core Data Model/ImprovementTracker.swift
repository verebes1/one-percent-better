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
   
   /// Actual score data points which align with dates array
   @NSManaged public var scores: [Double]
   
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
      self.scores = []
   }
   
   func add(date: Date, score: Double) {
      let value = String(Int(score))
      // check for duplicate date
      if let dateIndex = dates.sameDayBinarySearch(for: date) {
         values[dateIndex] = value
         scores[dateIndex] = score
      } else {
         dates.append(date)
         values.append(value)
         scores.append(score)
         
         // sort both lists by dates
         let valuesScores = zip(values, scores)
         let combined = zip(dates, valuesScores).sorted { $0.0 < $1.0 }
         dates = combined.map { $0.0 }
         values = combined.map { $0.1.0 }
         scores = combined.map { $0.1.1 }
      }
      context.fatalSave()
   }
   
   /// Create 1% better graph data
   /// - Parameter i: index in dates array to start recalculating the score
   /// Let c_{day} be whether or not the user completed the habit on that day. c_{day} = 1.01 if completed on day, and 0.995 if not
   /// Score is calculated as
   ///   habit start date:    0
   ///   first day:               100 * c_1                       = 101 or 100
   ///   second day:         100 * c_1 * c_2             = 102.01 or 100.5 or 100
   ///   third day:              100 * c_1 * c_2 * c_3   = 103.03 or 101.5 or 100
   ///   etc.
   ///
   ///   a = 1.01 / 0.995
   ///   b = 1 / a
   ///
   ///   if c_n = 1.01, then c_n * b = ! c_n
   ///   if c_n = 0.995 then c_n * a = ! c_n
   ///
   /// If we want to update day n to be different, we have to make sure it's different
   /// If it is different, then multiple everything that follows by either a or b depending on direction change of that day
   ///
   /// let start = score[day before date]
   /// let oldScore = score[date]
   /// let newScore = start * c_date
   /// if newScore != oldScore -> update
   ///
   /// Note: These must be calculated based on the frequency at that time period.
   /// If something is supposed to be twice a day then doing it once gets you 0.5% better
   /// This means the dates array may not contain every day
   ///
   func update(on date: Date) {
      
      var curDate: Date
      var score: Double
      
      if let i = dates.sameDayBinarySearch(for: date) {
         curDate = dates[i]
         if i > 0 {
            // Go off on yesterday's score
            score = scores[i-1] + 100
         } else {
            score = 100
            self.add(date: Cal.date(byAdding: .day, value: -1, to: habit.startDate)!, score: 0)
         }
      } else {
         if dates.isEmpty {
            curDate = habit.startDate
            score = 100
            
            // Start of graph needs to be a 0 from the day before beginning
            self.add(date: Cal.date(byAdding: .day, value: -1, to: habit.startDate)!, score: 0)
         } else {
            if Cal.startOfDay(for: date) > Cal.startOfDay(for: dates.last!) {
               curDate = dates.last!
               score = Double(values.last!)!
            } else {
               fatalError("Case not handled!!!")
            }
            //         let start = Cal.date(byAdding: .day, value: -1, to: habit.startDate)!
         }
      }
      
      let tomorrow = Cal.date(byAdding: .day, value: 1, to: Date())!
      
      while !Cal.isDate(curDate, inSameDayAs: tomorrow) {
         
         //         var oldScore: Double?
         //         if let oldScoreIndex = dates.sameDayBinarySearch(for: curDate) {
         //            oldScore = values[oldScoreIndex]
         //         }
         
         switch habit.frequency(on: curDate) {
         case .timesPerDay(let n):
            let tc = Double(habit.timesCompleted(on: curDate))
            let expected = Double(n)
            if tc > 0 {
               score *= 1.01 * tc / expected
            } else {
               score *= 0.995
            }
         case .daysInTheWeek(let days):
            if days.contains(curDate.weekdayOffset) {
               if habit.wasCompleted(on: curDate) {
                  score *= 1.01
               } else {
                  score *= 0.995
               }
            } else {
               // don't modify score, unless it was done anyways
               if habit.wasCompleted(on: curDate) {
                  score *= 1.01
               }
            }
         }
         
         score = max(100, score)
         let scaledScore = score - 100
         self.add(date: curDate, score: scaledScore)
         curDate = Cal.date(byAdding: .day, value: 1, to: curDate)!
      }
   }
   
   
   //      self.reset()
   //      createData(habit: habit)
   //      CoreDataManager.shared.saveContext()
   
   // Case 1: dates is empty, so start from habit.startDate
   // Case 2: dates has 1 entry, yesterday
   // Case 3: dates has 1 entry, many days ago
   // Case 4: dates has many entries, including yesterday
   
   //      [0, 1, 2, 3, 4, 5, ]
   
   
   //   func createData(from i: Int?) {
   //      let tomorrow = Cal.date(byAdding: .day, value: 1, to: Date())!
   //      var curDate: Date
   //      var score: Double
   //      if let i = i {
   //         curDate = dates[i]
   //         score = Double(values[i])!
   //      } else {
   //
   //         let start = Cal.date(byAdding: .day, value: -1, to: habit.startDate)!
   //
   //
   //         curDate = habit.startDate
   //         score = 100
   //      }
   //
   //      while !Cal.isDate(curDate, inSameDayAs: tomorrow) {
   //         if habit.wasCompleted(on: curDate) {
   //            score *= 1.01
   //         } else {
   //            score *= 0.995
   //
   //            if score < 100 {
   //               score = 100
   //            }
   //         }
   //         let roundedScore = round(score)
   //         let scaledScore = roundedScore - 100
   //         self.add(date: curDate, value: String(Int(scaledScore)))
   //         curDate = Cal.date(byAdding: .day, value: 1, to: curDate)!
   //      }
   //   }
   
   //   func createData(habit: Habit) {
   //      var score: Double = 100
   //      let tomorrow = Cal.date(byAdding: .day, value: 1, to: Date())!
   //      var curDate = habit.startDate
   //      while !Cal.isDate(curDate, inSameDayAs: tomorrow) {
   //         if habit.wasCompleted(on: curDate) {
   //            score *= 1.01
   //         } else {
   //            score *= 0.995
   //
   //            if score < 100 {
   //               score = 100
   //            }
   //         }
   //         let roundedScore = round(score)
   //         let scaledScore = roundedScore - 100
   //         self.add(date: curDate, value: String(Int(scaledScore)))
   //         curDate = Cal.date(byAdding: .day, value: 1, to: curDate)!
   //      }
   //   }
   
   // MARK: - Encodable
   enum CodingKeys: CodingKey {
      case name
      case autoTracker
      case index
      case dates
      case values
      case scores
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
      self.scores = container.decodeOptional(key: .scores, type: [Double].self) ?? []
   }
   
   public override func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(name, forKey: .name)
      try container.encode(autoTracker, forKey: .autoTracker)
      try container.encode(index, forKey: .index)
      try container.encode(dates, forKey: .dates)
      try container.encode(values, forKey: .values)
      try container.encode(scores, forKey: .scores)
   }
   
}

extension ImprovementTracker {
   @nonobjc public class func fetchRequest() -> NSFetchRequest<ImprovementTracker> {
      return NSFetchRequest<ImprovementTracker>(entityName: "ImprovementTracker")
   }
}
