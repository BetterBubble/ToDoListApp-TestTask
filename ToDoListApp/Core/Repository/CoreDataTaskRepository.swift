//
//  CoreDataTaskRepository.swift
//  ToDoListApp
//

import Foundation
import CoreData

/// Реализация репозитория для работы с Core Data
/// Следует принципам SOLID: Single Responsibility и Dependency Inversion
final class CoreDataTaskRepository: TaskRepositoryProtocol {

    // MARK: - Properties

    private let coreDataStack: CoreDataStackProtocol
    private let backgroundQueue = DispatchQueue(label: "com.todolist.repository", qos: .background)

    // MARK: - Init

    init(coreDataStack: CoreDataStackProtocol = CoreDataStack.shared) {
        self.coreDataStack = coreDataStack
    }

    // MARK: - TaskRepositoryProtocol

    func fetchAllTasks(completion: @escaping (Result<[Task], Error>) -> Void) {
        backgroundQueue.async { [weak self] in
            guard let self = self else { return }

            let context = self.coreDataStack.viewContext
            let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()

            // Сортировка по дате создания (новые сверху)
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

            do {
                let entities = try context.fetch(request)
                let tasks = entities.map { TaskEntityMapper.toDomain(from: $0) }
                print("Загружено задач: \(tasks.count)")

                DispatchQueue.main.async {
                    completion(.success(tasks))
                }
            } catch {
                print("Ошибка загрузки задач: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(CoreDataError.fetchFailed(error)))
                }
            }
        }
    }

    func fetchTask(by id: UUID, completion: @escaping (Result<Task?, Error>) -> Void) {
        backgroundQueue.async { [weak self] in
            guard let self = self else { return }

            let context = self.coreDataStack.viewContext
            let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1

            do {
                let entities = try context.fetch(request)
                let task = entities.first.map { TaskEntityMapper.toDomain(from: $0) }

                DispatchQueue.main.async {
                    completion(.success(task))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(CoreDataError.fetchFailed(error)))
                }
            }
        }
    }

    func createTask(_ task: Task, completion: @escaping (Result<Task, Error>) -> Void) {
        print("Создаем задачу: \(task.title)")

        coreDataStack.performBackgroundTask { context in
            _ = TaskEntityMapper.toEntity(from: task, in: context)

            do {
                try context.save()
                print("Задача сохранена в Core Data: \(task.title)")
                DispatchQueue.main.async {
                    // Принудительно обновляем view context для тестов
                    self.coreDataStack.viewContext.refreshAllObjects()
                    completion(.success(task))
                }
            } catch {
                print("Ошибка сохранения задачи: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(CoreDataError.saveFailed(error)))
                }
            }
        }
    }

    func updateTask(_ task: Task, completion: @escaping (Result<Task, Error>) -> Void) {
        coreDataStack.performBackgroundTask { context in
            let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
            request.fetchLimit = 1

            do {
                let entities = try context.fetch(request)
                guard let taskEntity = entities.first else {
                    DispatchQueue.main.async {
                        completion(.failure(CoreDataError.entityNotFound))
                    }
                    return
                }

                TaskEntityMapper.updateEntity(taskEntity, from: task)
                try context.save()

                DispatchQueue.main.async {
                    completion(.success(task))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(CoreDataError.saveFailed(error)))
                }
            }
        }
    }

    func deleteTask(by id: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        coreDataStack.performBackgroundTask { context in
            let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

            do {
                let entities = try context.fetch(request)
                entities.forEach { context.delete($0) }
                try context.save()

                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(CoreDataError.saveFailed(error)))
                }
            }
        }
    }

    func deleteAllTasks(completion: @escaping (Result<Void, Error>) -> Void) {
        coreDataStack.performBackgroundTask { context in
            let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()

            do {
                // Проверяем, не является ли это in-memory store (для тестов)
                let stores = context.persistentStoreCoordinator?.persistentStores ?? []
                let isInMemory = stores.contains { $0.type == NSInMemoryStoreType }

                if isInMemory {
                    // Для in-memory store используем обычное удаление
                    let entities = try context.fetch(request)
                    for entity in entities {
                        context.delete(entity)
                    }
                    try context.save()
                } else {
                    // Для production используем batch delete
                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: request as! NSFetchRequest<NSFetchRequestResult>)
                    deleteRequest.resultType = .resultTypeObjectIDs

                    let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
                    if let objectIDs = result?.result as? [NSManagedObjectID] {
                        NSManagedObjectContext.mergeChanges(
                            fromRemoteContextSave: [NSDeletedObjectsKey: objectIDs],
                            into: [self.coreDataStack.viewContext]
                        )
                    }
                }

                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(CoreDataError.saveFailed(error)))
                }
            }
        }
    }

    func searchTasks(with searchText: String, completion: @escaping (Result<[Task], Error>) -> Void) {
        backgroundQueue.async { [weak self] in
            guard let self = self else { return }

            let context = self.coreDataStack.viewContext
            let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()

            // Поиск по названию и описанию
            let titlePredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
            let descriptionPredicate = NSPredicate(format: "taskDescription CONTAINS[cd] %@", searchText)
            request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, descriptionPredicate])

            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

            do {
                let entities = try context.fetch(request)
                let tasks = entities.map { TaskEntityMapper.toDomain(from: $0) }

                DispatchQueue.main.async {
                    completion(.success(tasks))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(CoreDataError.fetchFailed(error)))
                }
            }
        }
    }

    func getTasksCount(completion: @escaping (Result<Int, Error>) -> Void) {
        backgroundQueue.async { [weak self] in
            guard let self = self else { return }

            let context = self.coreDataStack.viewContext
            let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()

            do {
                let count = try context.count(for: request)
                DispatchQueue.main.async {
                    completion(.success(count))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(CoreDataError.fetchFailed(error)))
                }
            }
        }
    }

    func saveTasksFromAPI(_ tasks: [Task], completion: @escaping (Result<Void, Error>) -> Void) {
        print("Сохраняем \(tasks.count) задач из API")

        coreDataStack.performBackgroundTask { context in
            // Сохраняем каждую задачу
            tasks.forEach { task in
                _ = TaskEntityMapper.toEntity(from: task, in: context)
            }

            do {
                try context.save()
                print("Успешно сохранено \(tasks.count) задач в Core Data")
                DispatchQueue.main.async {
                    // Принудительно обновляем view context для тестов
                    self.coreDataStack.viewContext.refreshAllObjects()
                    completion(.success(()))
                }
            } catch {
                print("Ошибка сохранения задач из API: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(CoreDataError.saveFailed(error)))
                }
            }
        }
    }
}
