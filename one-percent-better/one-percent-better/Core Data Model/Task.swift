//
//  Task.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/16/22.
//

import Foundation
import CoreData

@objc(Task)
public class Task: NSManagedObject, Codable {

    class func updateTaskList(from context: NSManagedObjectContext) -> [Task] {
        var tasks: [Task] = []
        do {
            // fetch all tasks
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            tasks = try context.fetch(fetchRequest)
        } catch {
            fatalError("Task.swift \(#function) - unable to fetch tasks!")
        }
        return tasks
    }
    
    // MARK: - Encodable
    
    enum CodingKeys: CodingKey {
        case name
        case completed
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw DecoderConfigurationError.missingManagedObjectContext
        }
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(context: context)
    
        let tasks = Task.updateTaskList(from: context)
        var name = try container.decode(String.self, forKey: .name)
        let today = Date()
        for task in tasks {
            if task.name == name {
                name = "\(name) (Imported on \(ExportManager.formatter.string(from: today)))"
            }
        }
        self.name = name
        self.completed = try container.decode(Bool.self, forKey: .completed)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(completed, forKey: .completed)
    }
}
