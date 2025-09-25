//
//  CoreDataTaskRepositoryTests.swift
//  ToDoListAppTests
//

import XCTest
import CoreData
@testable import ToDoListApp

final class CoreDataTaskRepositoryTests: XCTestCase {

    var sut: CoreDataTaskRepository!
    var mockCoreDataStack: MockCoreDataStack!

    override func setUp() {
        super.setUp()
        mockCoreDataStack = MockCoreDataStack()
        sut = CoreDataTaskRepository(coreDataStack: mockCoreDataStack)
    }

    override func tearDown() {
        clearAllData()
        sut = nil
        mockCoreDataStack = nil
        super.tearDown()
    }

    private func clearAllData() {
        let context = mockCoreDataStack.viewContext
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()

        do {
            let entities = try context.fetch(request)
            for entity in entities {
                context.delete(entity)
            }
            if context.hasChanges {
                try context.save()
            }
        } catch {
            print("Failed to clear data: \(error)")
        }
    }

    // MARK: - Create Task Tests

    func testCreateTask_Success_SavesTaskToCoreData() {
        let task = Task(
            id: UUID(),
            title: "Test Task",
            description: "Test Description",
            isCompleted: false,
            createdAt: Date()
        )

        let expectation = self.expectation(description: "Create task")
        var resultTask: Task?

        sut.createTask(task) { result in
            if case .success(let createdTask) = result {
                resultTask = createdTask
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0)

        XCTAssertNotNil(resultTask)
        XCTAssertEqual(resultTask?.id, task.id)
        XCTAssertEqual(resultTask?.title, "Test Task")
    }

    // MARK: - Fetch All Tasks Tests

    func testFetchAllTasks_WithNoTasks_ReturnsEmptyArray() {
        let expectation = self.expectation(description: "Fetch all tasks")
        var resultTasks: [Task]?

        sut.fetchAllTasks { result in
            if case .success(let tasks) = result {
                resultTasks = tasks
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0)

        XCTAssertEqual(resultTasks?.count, 0)
    }

    func testFetchAllTasks_WithTasks_ReturnsAllTasks() {
        let task1 = Task(id: UUID(), title: "Task 1", description: nil, isCompleted: false, createdAt: Date())
        let task2 = Task(id: UUID(), title: "Task 2", description: nil, isCompleted: true, createdAt: Date())

        let createExpectation1 = self.expectation(description: "Create task 1")
        sut.createTask(task1) { _ in createExpectation1.fulfill() }

        let createExpectation2 = self.expectation(description: "Create task 2")
        sut.createTask(task2) { _ in createExpectation2.fulfill() }

        wait(for: [createExpectation1, createExpectation2], timeout: 5.0)


        let fetchExpectation = self.expectation(description: "Fetch all tasks")
        var resultTasks: [Task]?

        sut.fetchAllTasks { result in
            if case .success(let tasks) = result {
                resultTasks = tasks
            }
            fetchExpectation.fulfill()
        }

        waitForExpectations(timeout: 5.0)

        XCTAssertEqual(resultTasks?.count, 2)
    }

    func testFetchAllTasks_SortsByCreatedDateDescending() {
        let olderTask = Task(
            id: UUID(),
            title: "Older Task",
            description: nil,
            isCompleted: false,
            createdAt: Date(timeIntervalSince1970: 1000)
        )
        let newerTask = Task(
            id: UUID(),
            title: "Newer Task",
            description: nil,
            isCompleted: false,
            createdAt: Date(timeIntervalSince1970: 2000)
        )

        let createExpectation1 = self.expectation(description: "Create older task")
        sut.createTask(olderTask) { _ in createExpectation1.fulfill() }

        let createExpectation2 = self.expectation(description: "Create newer task")
        sut.createTask(newerTask) { _ in createExpectation2.fulfill() }

        wait(for: [createExpectation1, createExpectation2], timeout: 5.0)


        let fetchExpectation = self.expectation(description: "Fetch all tasks")
        var resultTasks: [Task]?

        sut.fetchAllTasks { result in
            if case .success(let tasks) = result {
                resultTasks = tasks
            }
            fetchExpectation.fulfill()
        }

        waitForExpectations(timeout: 5.0)

        XCTAssertEqual(resultTasks?.first?.title, "Newer Task")
        XCTAssertEqual(resultTasks?.last?.title, "Older Task")
    }

    // MARK: - Fetch Task By ID Tests

    func testFetchTask_WithExistingId_ReturnsTask() {
        let task = Task(id: UUID(), title: "Test Task", description: nil, isCompleted: false, createdAt: Date())

        let createExpectation = self.expectation(description: "Create task")
        sut.createTask(task) { _ in createExpectation.fulfill() }

        wait(for: [createExpectation], timeout: 5.0)


        let fetchExpectation = self.expectation(description: "Fetch task by ID")
        var resultTask: Task?

        sut.fetchTask(by: task.id) { result in
            if case .success(let fetchedTask) = result {
                resultTask = fetchedTask
            }
            fetchExpectation.fulfill()
        }

        waitForExpectations(timeout: 5.0)

        XCTAssertNotNil(resultTask)
        XCTAssertEqual(resultTask?.id, task.id)
        XCTAssertEqual(resultTask?.title, "Test Task")
    }

    func testFetchTask_WithNonExistingId_ReturnsNil() {
        let nonExistingId = UUID()

        let expectation = self.expectation(description: "Fetch non-existing task")
        var resultTask: Task?

        sut.fetchTask(by: nonExistingId) { result in
            if case .success(let fetchedTask) = result {
                resultTask = fetchedTask
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0)

        XCTAssertNil(resultTask)
    }

    // MARK: - Update Task Tests

    func testUpdateTask_WithExistingTask_UpdatesSuccessfully() {
        let task = Task(id: UUID(), title: "Original Title", description: "Original Description", isCompleted: false, createdAt: Date())

        let createExpectation = self.expectation(description: "Create task")
        sut.createTask(task) { _ in createExpectation.fulfill() }

        wait(for: [createExpectation], timeout: 5.0)


        let updatedTask = Task(
            id: task.id,
            title: "Updated Title",
            description: "Updated Description",
            isCompleted: true,
            createdAt: task.createdAt
        )

        let updateExpectation = self.expectation(description: "Update task")
        var resultTask: Task?

        sut.updateTask(updatedTask) { result in
            if case .success(let task) = result {
                resultTask = task
            }
            updateExpectation.fulfill()
        }

        waitForExpectations(timeout: 5.0)

        XCTAssertEqual(resultTask?.title, "Updated Title")
        XCTAssertEqual(resultTask?.description, "Updated Description")
        XCTAssertEqual(resultTask?.isCompleted, true)
    }

    func testUpdateTask_WithNonExistingTask_ReturnsError() {
        let nonExistingTask = Task(id: UUID(), title: "Non-existing", description: nil, isCompleted: false, createdAt: Date())

        let expectation = self.expectation(description: "Update non-existing task")
        var resultError: Error?

        sut.updateTask(nonExistingTask) { result in
            if case .failure(let error) = result {
                resultError = error
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0)

        XCTAssertNotNil(resultError)
    }

    // MARK: - Delete Task Tests

    func testDeleteTask_WithExistingId_DeletesSuccessfully() {
        let task = Task(id: UUID(), title: "Task to Delete", description: nil, isCompleted: false, createdAt: Date())

        let createExpectation = self.expectation(description: "Create task")
        sut.createTask(task) { _ in createExpectation.fulfill() }

        wait(for: [createExpectation], timeout: 5.0)


        let deleteExpectation = self.expectation(description: "Delete task")

        sut.deleteTask(by: task.id) { result in
            XCTAssertTrue(result.isSuccess)
            deleteExpectation.fulfill()
        }

        waitForExpectations(timeout: 5.0)

        let fetchExpectation = self.expectation(description: "Fetch deleted task")
        var resultTask: Task?

        sut.fetchTask(by: task.id) { result in
            if case .success(let fetchedTask) = result {
                resultTask = fetchedTask
            }
            fetchExpectation.fulfill()
        }

        wait(for: [fetchExpectation], timeout: 5.0)

        XCTAssertNil(resultTask)
    }

    // MARK: - Search Tasks Tests

    func testSearchTasks_FindsTasksByTitle() {
        let task1 = Task(id: UUID(), title: "Important Meeting", description: "Discuss project", isCompleted: false, createdAt: Date())
        let task2 = Task(id: UUID(), title: "Buy Groceries", description: "Milk and bread", isCompleted: false, createdAt: Date())

        let createExpectation1 = self.expectation(description: "Create task 1")
        sut.createTask(task1) { _ in createExpectation1.fulfill() }

        let createExpectation2 = self.expectation(description: "Create task 2")
        sut.createTask(task2) { _ in createExpectation2.fulfill() }

        wait(for: [createExpectation1, createExpectation2], timeout: 5.0)


        let searchExpectation = self.expectation(description: "Search tasks")
        var resultTasks: [Task]?

        sut.searchTasks(with: "Meeting") { result in
            if case .success(let tasks) = result {
                resultTasks = tasks
            }
            searchExpectation.fulfill()
        }

        waitForExpectations(timeout: 5.0)

        XCTAssertEqual(resultTasks?.count, 1)
        XCTAssertEqual(resultTasks?.first?.title, "Important Meeting")
    }

    func testSearchTasks_FindsTasksByDescription() {
        let task = Task(id: UUID(), title: "Shopping", description: "Buy milk and eggs", isCompleted: false, createdAt: Date())

        let createExpectation = self.expectation(description: "Create task")
        sut.createTask(task) { _ in createExpectation.fulfill() }

        wait(for: [createExpectation], timeout: 5.0)


        let searchExpectation = self.expectation(description: "Search tasks")
        var resultTasks: [Task]?

        sut.searchTasks(with: "milk") { result in
            if case .success(let tasks) = result {
                resultTasks = tasks
            }
            searchExpectation.fulfill()
        }

        waitForExpectations(timeout: 5.0)

        XCTAssertEqual(resultTasks?.count, 1)
        XCTAssertEqual(resultTasks?.first?.title, "Shopping")
    }

    func testSearchTasks_IsCaseInsensitive() {
        let task = Task(id: UUID(), title: "Important Task", description: nil, isCompleted: false, createdAt: Date())

        let createExpectation = self.expectation(description: "Create task")
        sut.createTask(task) { _ in createExpectation.fulfill() }

        wait(for: [createExpectation], timeout: 5.0)


        let searchExpectation = self.expectation(description: "Search tasks")
        var resultTasks: [Task]?

        sut.searchTasks(with: "important") { result in
            if case .success(let tasks) = result {
                resultTasks = tasks
            }
            searchExpectation.fulfill()
        }

        waitForExpectations(timeout: 5.0)

        XCTAssertEqual(resultTasks?.count, 1)
    }

    // MARK: - Get Tasks Count Tests

    func testGetTasksCount_WithNoTasks_ReturnsZero() {
        let expectation = self.expectation(description: "Get tasks count")
        var count: Int?

        sut.getTasksCount { result in
            if case .success(let taskCount) = result {
                count = taskCount
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0)

        XCTAssertEqual(count, 0)
    }

    func testGetTasksCount_WithTasks_ReturnsCorrectCount() {
        let task1 = Task(id: UUID(), title: "Task 1", description: nil, isCompleted: false, createdAt: Date())
        let task2 = Task(id: UUID(), title: "Task 2", description: nil, isCompleted: false, createdAt: Date())

        let createExpectation1 = self.expectation(description: "Create task 1")
        sut.createTask(task1) { _ in createExpectation1.fulfill() }

        let createExpectation2 = self.expectation(description: "Create task 2")
        sut.createTask(task2) { _ in createExpectation2.fulfill() }

        wait(for: [createExpectation1, createExpectation2], timeout: 5.0)


        let countExpectation = self.expectation(description: "Get tasks count")
        var count: Int?

        sut.getTasksCount { result in
            if case .success(let taskCount) = result {
                count = taskCount
            }
            countExpectation.fulfill()
        }

        waitForExpectations(timeout: 5.0)

        XCTAssertEqual(count, 2)
    }

    // MARK: - Save Tasks From API Tests

    func testSaveTasksFromAPI_SavesMultipleTasks() {
        let tasks = [
            Task(id: UUID(), title: "API Task 1", description: nil, isCompleted: false, createdAt: Date()),
            Task(id: UUID(), title: "API Task 2", description: nil, isCompleted: true, createdAt: Date()),
            Task(id: UUID(), title: "API Task 3", description: "Description", isCompleted: false, createdAt: Date())
        ]

        let saveExpectation = self.expectation(description: "Save tasks from API")

        sut.saveTasksFromAPI(tasks) { result in
            XCTAssertTrue(result.isSuccess)
            saveExpectation.fulfill()
        }

        waitForExpectations(timeout: 5.0)

        let fetchExpectation = self.expectation(description: "Fetch all tasks")
        var resultTasks: [Task]?

        sut.fetchAllTasks { result in
            if case .success(let fetchedTasks) = result {
                resultTasks = fetchedTasks
            }
            fetchExpectation.fulfill()
        }

        wait(for: [fetchExpectation], timeout: 5.0)

        XCTAssertEqual(resultTasks?.count, 3)
    }

    // MARK: - Delete All Tasks Tests

    func testDeleteAllTasks_RemovesAllTasks() {
        let task1 = Task(id: UUID(), title: "Task 1", description: nil, isCompleted: false, createdAt: Date())
        let task2 = Task(id: UUID(), title: "Task 2", description: nil, isCompleted: false, createdAt: Date())

        let createExpectation1 = self.expectation(description: "Create task 1")
        sut.createTask(task1) { _ in createExpectation1.fulfill() }

        let createExpectation2 = self.expectation(description: "Create task 2")
        sut.createTask(task2) { _ in createExpectation2.fulfill() }

        wait(for: [createExpectation1, createExpectation2], timeout: 5.0)


        let deleteExpectation = self.expectation(description: "Delete all tasks")

        sut.deleteAllTasks { result in
            XCTAssertTrue(result.isSuccess)
            deleteExpectation.fulfill()
        }

        waitForExpectations(timeout: 5.0)

        let fetchExpectation = self.expectation(description: "Fetch all tasks")
        var resultTasks: [Task]?

        sut.fetchAllTasks { result in
            if case .success(let tasks) = result {
                resultTasks = tasks
            }
            fetchExpectation.fulfill()
        }

        wait(for: [fetchExpectation], timeout: 5.0)

        XCTAssertEqual(resultTasks?.count, 0)
    }
}