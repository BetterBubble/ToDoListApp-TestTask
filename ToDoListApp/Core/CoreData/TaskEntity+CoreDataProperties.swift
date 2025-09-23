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

// MARK: - Конвертация в доменную модель
extension TaskEntity {

    /// Конвертирует Core Data entity в доменную модель Task
    func toDomainModel() -> Task {
        return Task(
            id: id ?? UUID(),
            title: title ?? "",
            description: taskDescription,
            isCompleted: isCompleted,
            createdAt: createdAt ?? Date()
        )
    }

    /// Обновляет entity из доменной модели
    func update(from task: Task) {
        self.id = task.id
        self.title = task.title
        self.taskDescription = task.description
        self.isCompleted = task.isCompleted
        self.createdAt = task.createdAt
    }
}