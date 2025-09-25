//
//  MockCoreDataStack.swift
//  ToDoListAppTests
//

import Foundation
import CoreData
@testable import ToDoListApp

final class MockCoreDataStack: CoreDataStackProtocol {

    var performBackgroundTaskCalled = false
    var lastBackgroundTask: ((NSManagedObjectContext) -> Void)?

    lazy var persistentContainer: NSPersistentContainer = {
        // Получаем модель из основного бандла приложения
        let bundle = Bundle.main
        guard let modelURL = bundle.url(forResource: "ToDoListModel", withExtension: "momd") else {
            fatalError("Failed to find data model")
        }
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to create model from file: \(modelURL)")
        }

        let container = NSPersistentContainer(name: "ToDoListModel", managedObjectModel: managedObjectModel)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load in-memory store: \(error)")
            }
        }

        // Настройка контекста для тестов
        container.viewContext.automaticallyMergesChangesFromParent = true

        return container
    }()

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func save() throws {
        let context = viewContext
        if context.hasChanges {
            try context.save()
        }
    }

    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        performBackgroundTaskCalled = true
        lastBackgroundTask = block
        persistentContainer.performBackgroundTask { context in
            block(context)
            // Принудительное слияние изменений с main context
            DispatchQueue.main.async { [weak self] in
                self?.viewContext.refreshAllObjects()
            }
        }
    }
}