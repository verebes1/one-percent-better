//
//  ImprovementTracker.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 1/23/22.
//

import Foundation
import CoreData

struct GraphPoint: Equatable {
   var date: Date
   var value: Double
}

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
   
   func scoreToValue(for score: Double) -> String {
      let roundedScore = round(score)
      let string = String(Int(roundedScore))
      return string
   }
   
   /// Get the last n days of the improvement score starting from date
   /// - Returns: Array of graph points
   func lastNDays(n: Int, on date: Date) -> [GraphPoint] {
      //      update(on: date)
      var r = [GraphPoint]()
      if var i = dates.lessThanOrEqualSearch(for: date) {
         for _ in 0 ..< n {
            if i >= 0 {
               r.append(GraphPoint(date: dates[i], value: scores[i]))
            } else {
               break
            }
            i -= 1
         }
      }
      return r.reversed()
   }
   
   func add(date: Date, score: Double) {
      //      let value = String(Int(score))
      let value = scoreToValue(for: score)
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
   }
   
   override func remove(on date: Date) {
      if let index = dates.sameDayBinarySearch(for: date) {
         dates.remove(at: index)
         values.remove(at: index)
         scores.remove(at: index)
      }
   }
   
   func score(on date: Date) -> Double? {
      if let index = dates.sameDayBinarySearch(for: date) {
         return scores[index]
      } else if habit.isDue(on: date) {
         update(on: date)
         if let index = dates.sameDayBinarySearch(for: date) {
            return scores[index]
         } else {
            return nil
         }
      } else {
         return nil
      }
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
      
      if let i = dates.lessThanOrEqualSearch(for: date),
         i > 0 {
         curDate = dates[i]
         score = scores[i-1] + 100
      } else {
         curDate = habit.startDate
         score = 100
         // Start of graph needs to be a 0 from the day before beginning
         //         self.add(date: Cal.date(byAdding: .day, value: -1, to: habit.startDate)!, score: 0)
      }
      
      let tomorrow = Cal.date(byAdding: .day, value: 1, to: Date())!
      
      while !Cal.isDate(curDate, inSameDayAs: tomorrow) {
         var toRemove = false
         guard let freq = habit.frequency(on: curDate) else { return }
         
         switch freq {
         case .timesPerDay(let n):
            let tc = Double(habit.timesCompleted(on: curDate))
            let expected = Double(n)
            if tc > 0 {
               score *= (1 + (0.01 * tc / expected))
            } else {
               score *= 0.995
            }
         case .daysInTheWeek(let days):
            if days.contains(curDate.weekdayInt) {
               if habit.wasCompleted(on: curDate) {
                  score *= 1.01
               } else {
                  score *= 0.995
               }
            } else {
               // Only increase score if completed
               // Remove score if not
               if habit.wasCompleted(on: curDate) {
                  score *= 1.01
               } else {
                  toRemove = true
               }
            }
         case .timesPerWeek(times: let n, resetDay: let resetDay):
            let tc = Double(habit.timesCompleted(on: curDate))
            let expected = Double(n)
            
            var timesCompletedThisWeek = 0
            for i in 0 ..< 7 {
               let day = Cal.date(byAdding: .day, value: -i, to: curDate)!
               timesCompletedThisWeek += habit.timesCompleted(on: day)
            }
            
            if timesCompletedThisWeek > 0 || curDate.weekdayInt != resetDay.rawValue {
               if tc == 0 {
                  toRemove = true
               } else {
                  score *= (1 + (0.01 * tc / expected))
               }
            } else {
               if curDate.weekdayInt == resetDay.rawValue {
                  score *= 0.995
               } else {
                  toRemove = true
               }
            }
         }
         
         score = max(100, score)
         let scaledScore = score - 100
         if !toRemove {
            add(date: curDate, score: scaledScore)
         } else {
            remove(on: curDate)
         }
         curDate = Cal.date(byAdding: .day, value: 1, to: curDate)!
      }
      context.fatalSave()
   }
   
   func recalculateScoreFromBeginning() {
      dates = []
      scores = []
      values = []
      update(on: habit.startDate)
   }
   
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
      self.scores = container.decodeOptional(key: .scores, type: [Double].self) ?? self.values.map { Double(Int($0)!) }
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
