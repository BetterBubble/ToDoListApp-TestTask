//
//  SimpleCoreDataTaskRepositoryTests.swift
//  ToDoListAppTests
//

import XCTest
import CoreData
@testable import ToDoListApp

/// Упрощенная версия тестов для CoreDataTaskRepository
/// которая должна работать более стабильно
final class SimpleCoreDataTaskRepositoryTests: XCTestCase {

    var sut: CoreDataTaskRepository!
    var coreDataStack: CoreDataStackProtocol!

    override func setUp() {
        super.setUp()

        // Создаем простой in-memory Core Data stack
        coreDataStack = TestCoreDataStack()
        sut = CoreDataTaskRepository(coreDataStack: coreDataStack)
    }

    override func tearDown() {
        sut = nil
        coreDataStack = nil
        super.tearDown()
    }

    // Простой тест создания
    func testCreateAndFetch() {
        let expectation = self.expectation(description: "Create and fetch")
        let taskId = UUID()
        let task = Task(
            id: taskId,
            title: "Test Task",
            description: "Test Description",
            isCompleted: false,
            createdAt: Date()
        )

        // Создаем задачу
        sut.createTask(task) { [weak self] result in
            guard let self = self else { return }

            if case .success = result {
                // Сразу пробуем получить
                self.sut.fetchTask(by: taskId) { fetchResult in
                    if case .success(let fetchedTask) = fetchResult {
                        XCTAssertNotNil(fetchedTask)
                        XCTAssertEqual(fetchedTask?.title, "Test Task")
                    }
                    expectation.fulfill()
                }
            } else {
                XCTFail("Failed to create task")
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 10.0)
    }

    // Тест удаления
    func testDelete() {
        let expectation = self.expectation(description: "Delete task")
        let taskId = UUID()
        let task = Task(
            id: taskId,
            title: "Task to Delete",
            description: nil,
            isCompleted: false,
            createdAt: Date()
        )

        // Создаем, затем удаляем
        sut.createTask(task) { [weak self] _ in
            guard let self = self else { return }

            // Удаляем
            self.sut.deleteTask(by: taskId) { deleteResult in
                if case .success = deleteResult {
                    // Проверяем что задача удалена
                    self.sut.fetchTask(by: taskId) { fetchResult in
                        if case .success(let fetchedTask) = fetchResult {
                            XCTAssertNil(fetchedTask, "Task should be deleted")
                        }
                        expectation.fulfill()
                    }
                } else {
                    XCTFail("Failed to delete task")
                    expectation.fulfill()
                }
            }
        }

        waitForExpectations(timeout: 10.0)
    }
}

/// Простой тестовый Core Data Stack
class TestCoreDataStack: CoreDataStackProtocol {

    lazy var persistentContainer: NSPersistentContainer = {
        // Получаем модель из основного бандла
        let bundle = Bundle(for: CoreDataStack.self)
        guard let modelURL = bundle.url(forResource: "ToDoListModel", withExtension: "momd") else {
            fatalError("Failed to find data model")
        }
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to create model from file: \(modelURL)")
        }

        let container = NSPersistentContainer(name: "ToDoListModel", managedObjectModel: managedObjectModel)

        // Настраиваем in-memory store для тестов
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load in-memory store: \(error)")
            }
        }

        // Важно: настраиваем merge policy для избежания конфликтов
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
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
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.perform {
            block(context)
        }
    }
}