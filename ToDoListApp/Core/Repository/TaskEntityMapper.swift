//
//  TaskEntityMapper.swift
//  ToDoListApp
//

import Foundation
import CoreData

/// Mapper для конвертации между Core Data TaskEntity и Domain Task
/// Изолирует Domain слой от деталей реализации Core Data
enum TaskEntityMapper {

    /// Конвертирует Core Data entity в доменную модель Task
    static func toDomain(from entity: TaskEntity) -> Task {
        return Task(
            id: entity.id ?? UUID(),
            title: entity.title ?? "",
            description: entity.taskDescription,
            isCompleted: entity.isCompleted,
            createdAt: entity.createdAt ?? Date()
        )
    }

    /// Создает новый TaskEntity из доменной модели Task
    static func toEntity(from task: Task, in context: NSManagedObjectContext) -> TaskEntity {
        let entity = TaskEntity(context: context)
        updateEntity(entity, from: task)
        return entity
    }

    /// Обновляет существующий TaskEntity данными из доменной модели Task
    static func updateEntity(_ entity: TaskEntity, from task: Task) {
        entity.id = task.id
        entity.title = task.title
        entity.taskDescription = task.description
        entity.isCompleted = task.isCompleted
        entity.createdAt = task.createdAt
    }
}