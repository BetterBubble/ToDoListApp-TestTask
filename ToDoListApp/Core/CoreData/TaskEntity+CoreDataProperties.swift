//
//  TaskEntity+CoreDataProperties.swift
//  ToDoListApp
//

import Foundation
import CoreData

extension TaskEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskEntity> {
        return NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var taskDescription: String?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var remoteId: Int32
}

