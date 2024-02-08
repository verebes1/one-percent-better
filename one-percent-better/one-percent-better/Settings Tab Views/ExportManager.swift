//
//  ExportManager.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/16/22.
//

import Foundation
import CoreData

struct ExportContainer: Codable {
    let habits: [Habit]
    //    let tasks: [Task]
    let featureLog: FeatureLog
}

extension JSONDecoder.DateDecodingStrategy {
    static let customMultipleFormats = custom { decoder -> Date in
        let container = try decoder.singleValueContainer()
        let dateStr = try container.decode(String.self)
        
        // Shared DateFormatter instance for efficiency
        let dateFormatter = DateFormatter()
        
        // Define an array of expected date formats
        let dateFormats = [
            "MM-dd-yyyy HH:mm",
            "MM/dd/yy" // Add more formats as needed
        ]
        
        for dateFormat in dateFormats {
            dateFormatter.dateFormat = dateFormat
            if let date = dateFormatter.date(from: dateStr) {
                return date
            }
        }
        
        // If none of the date formats worked, throw an error
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string: \(dateStr)")
    }
}

class ExportManager: NSObject {
    
    /// Format the date into style MM/DD/YYYY
    public static var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy HH:mm"
        return formatter
    }()
    
    /// Encode the json with specific date formatter
    lazy var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .formatted(ExportManager.formatter)
        return encoder
    }()
    
    /// Decode json with specific date formatter
    lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        // Set up the ManagedObjectContext for encoding and decoding ManagedObjects
        decoder.userInfo[CodingUserInfoKey.managedObjectContext] = CoreDataManager.shared.mainContext
        decoder.dateDecodingStrategy = .customMultipleFormats
        return decoder
    }()
    
    func createJSON(context: NSManagedObjectContext) -> URL? {
        // Create ExportContainer object
        let habits = Habit.habits(from: context)
        guard let featureLog = FeatureLog.getFeatureLog(from: context) else { return nil }
        let container = ExportContainer(habits: habits, featureLog: featureLog)
        
        if let jsonData = try? encoder.encode(container) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                let documentsDirectoryURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                
                // FIXME: Add todays date into file name so we have backups
                //                let date = ExportManager.formatter.string(from: Date())
                
                let fileName = "1PercentBetter.json"
                let file = documentsDirectoryURL.appendingPathComponent(fileName)
                do {
                    try jsonString.write(to: file, atomically: false, encoding: .utf8)
                    return file
                } catch {
                    print(error)
                }
            }
        }
        return nil
    }
    
    // Taken from: https://developer.apple.com/tutorials/swiftui/building-lists-and-navigation
    func load<T: Decodable>(_ data: Data) throws -> T {
        // Reset largestIndexBeforeImporting
        defer {
            Habit.nextLargestIndexBeforeImporting = nil
        }
        
        return try decoder.decode(T.self, from: data)
    }
    
}
