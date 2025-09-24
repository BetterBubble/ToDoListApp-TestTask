//
//  TaskDataManagerTests.swift
//  ToDoListAppTests
//

import XCTest
@testable import ToDoListApp

final class TaskDataManagerTests: XCTestCase {

    var sut: TaskDataManager!
    var mockRepository: MockTaskRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockTaskRepository()
        sut = TaskDataManager(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Fetch All Tasks Tests

    func testFetchAllTasks_Success() {
        let expectedTasks = [
            Task(id: UUID(), title: "Task 1", description: "Description 1", isCompleted: false, createdAt: Date()),
            Task(id: UUID(), title: "Task 2", description: "Description 2", isCompleted: true, createdAt: Date())
        ]
        mockRepository.fetchAllTasksResult = .success(expectedTasks)

        let expectation = self.expectation(description: "Fetch all tasks")
        var resultTasks: [Task]?

        sut.fetchAllTasks { result in
            if case .success(let tasks) = result {
                resultTasks = tasks
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)

        XCTAssertTrue(mockRepository.fetchAllTasksCalled)
        XCTAssertEqual(resultTasks?.count, 2)
        XCTAssertEqual(resultTasks?.first?.title, "Task 1")
    }

    func testFetchAllTasks_Failure() {
        mockRepository.fetchAllTasksResult = .failure(TaskError.taskNotFound)

        let expectation = self.expectation(description: "Fetch all tasks failure")
        var resultError: Error?

        sut.fetchAllTasks { result in
            if case .failure(let error) = result {
                resultError = error
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)

        XCTAssertTrue(mockRepository.fetchAllTasksCalled)
        XCTAssertNotNil(resultError)
    }

    // MARK: - Create Task Tests

    func testCreateTask_Success_WithValidTitle() {
        let newTask = Task(id: UUID(), title: "New Task", description: "Description", isCompleted: false, createdAt: Date())
        mockRepository.createTaskResult = .success(newTask)

        let expectation = self.expectation(description: "Create task")
        var createdTask: Task?

        sut.createTask(with: "New Task", description: "Description") { result in
            if case .success(let task) = result {
                createdTask = task
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)

        XCTAssertTrue(mockRepository.createTaskCalled)
        XCTAssertEqual(mockRepository.lastCreatedTask?.title, "New Task")
        XCTAssertEqual(createdTask?.title, "New Task")
    }

    func testCreateTask_Failure_WithEmptyTitle() {
        let expectation = self.expectation(description: "Create task with empty title")
        var resultError: Error?

        sut.createTask(with: "   ", description: "Description") { result in
            if case .failure(let error) = result {
                resultError = error
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)

        XCTAssertFalse(mockRepository.createTaskCalled)
        XCTAssertNotNil(resultError)
        XCTAssertEqual((resultError as? TaskError), TaskError.invalidTitle)
    }

    func testCreateTask_TrimsWhitespace() {
        let newTask = Task(id: UUID(), title: "Trimmed Task", description: nil, isCompleted: false, createdAt: Date())
        mockRepository.createTaskResult = .success(newTask)

        let expectation = self.expectation(description: "Create task with whitespace")

        sut.createTask(with: "  Trimmed Task  ", description: nil) { _ in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)

        XCTAssertEqual(mockRepository.lastCreatedTask?.title, "Trimmed Task")
    }

    // MARK: - Update Task Tests

    func testUpdateTask_Success() {
        let task = Task(id: UUID(), title: "Old Title", description: "Old Description", isCompleted: false, createdAt: Date())
        let updatedTask = Task(id: task.id, title: "New Title", description: "New Description", isCompleted: false, createdAt: task.createdAt)
        mockRepository.updateTaskResult = .success(updatedTask)

        let expectation = self.expectation(description: "Update task")
        var resultTask: Task?

        sut.updateTask(updatedTask) { result in
            if case .success(let task) = result {
                resultTask = task
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)

        XCTAssertTrue(mockRepository.updateTaskCalled)
        XCTAssertEqual(resultTask?.title, "New Title")
    }

    func testUpdateTask_Failure_WithEmptyTitle() {
        let task = Task(id: UUID(), title: "  ", description: "Description", isCompleted: false, createdAt: Date())

        let expectation = self.expectation(description: "Update task with empty title")
        var resultError: Error?

        sut.updateTask(task) { result in
            if case .failure(let error) = result {
                resultError = error
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)

        XCTAssertFalse(mockRepository.updateTaskCalled)
        XCTAssertEqual((resultError as? TaskError), TaskError.invalidTitle)
    }

    // MARK: - Delete Task Tests

    func testDeleteTask_Success() {
        let taskId = UUID()
        mockRepository.deleteTaskResult = .success(())

        let expectation = self.expectation(description: "Delete task")

        sut.deleteTask(by: taskId) { result in
            XCTAssertTrue(result.isSuccess)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)

        XCTAssertTrue(mockRepository.deleteTaskCalled)
        XCTAssertEqual(mockRepository.lastDeletedTaskId, taskId)
    }

    // MARK: - Search Tasks Tests

    func testSearchTasks_WithEmptyText_FetchesAllTasks() {
        let allTasks = [Task(id: UUID(), title: "Task", description: nil, isCompleted: false, createdAt: Date())]
        mockRepository.fetchAllTasksResult = .success(allTasks)

        let expectation = self.expectation(description: "Search with empty text")

        sut.searchTasks(with: "   ") { _ in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)

        XCTAssertTrue(mockRepository.fetchAllTasksCalled)
        XCTAssertFalse(mockRepository.searchTasksCalled)
    }

    func testSearchTasks_WithText_CallsSearch() {
        let searchResults = [Task(id: UUID(), title: "Found Task", description: nil, isCompleted: false, createdAt: Date())]
        mockRepository.searchTasksResult = .success(searchResults)

        let expectation = self.expectation(description: "Search with text")
        var resultTasks: [Task]?

        sut.searchTasks(with: "Found") { result in
            if case .success(let tasks) = result {
                resultTasks = tasks
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)

        XCTAssertTrue(mockRepository.searchTasksCalled)
        XCTAssertEqual(mockRepository.lastSearchText, "Found")
        XCTAssertEqual(resultTasks?.count, 1)
    }

    // MARK: - Toggle Task Completion Tests

    func testToggleTaskCompletion_Success() {
        let taskId = UUID()
        let task = Task(id: taskId, title: "Task", description: nil, isCompleted: false, createdAt: Date())
        let toggledTask = Task(id: taskId, title: "Task", description: nil, isCompleted: true, createdAt: Date())

        mockRepository.fetchTaskResult = .success(task)
        mockRepository.updateTaskResult = .success(toggledTask)

        let expectation = self.expectation(description: "Toggle completion")
        var resultTask: Task?

        sut.toggleTaskCompletion(for: taskId) { result in
            if case .success(let task) = result {
                resultTask = task
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)

        XCTAssertTrue(mockRepository.fetchTaskCalled)
        XCTAssertTrue(mockRepository.updateTaskCalled)
        XCTAssertEqual(resultTask?.isCompleted, true)
    }

    func testToggleTaskCompletion_Failure_TaskNotFound() {
        let taskId = UUID()
        mockRepository.fetchTaskResult = .success(nil)

        let expectation = self.expectation(description: "Toggle completion - task not found")
        var resultError: Error?

        sut.toggleTaskCompletion(for: taskId) { result in
            if case .failure(let error) = result {
                resultError = error
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)

        XCTAssertEqual((resultError as? TaskError), TaskError.taskNotFound)
    }
}