//
//  TaskDetailPresenterTests.swift
//  ToDoListAppTests
//

import XCTest
@testable import ToDoListApp

final class TaskDetailPresenterTests: XCTestCase {

    var sut: TaskDetailPresenter!
    var mockView: MockTaskDetailView!
    var mockInteractor: MockTaskDetailInteractor!

    override func setUp() {
        super.setUp()
        mockView = MockTaskDetailView()
        mockInteractor = MockTaskDetailInteractor()
        sut = TaskDetailPresenter()
        sut.view = mockView
        sut.interactor = mockInteractor
    }

    override func tearDown() {
        sut = nil
        mockView = nil
        mockInteractor = nil
        super.tearDown()
    }

    // MARK: - View Did Load Tests

    func testViewDidLoad_WithNewTask_DisplaysInitialState() {
        sut.task = nil

        sut.viewDidLoad()

        XCTAssertTrue(mockView.setupInitialStateCalled)
        XCTAssertTrue(mockView.displayTaskCalled)
        XCTAssertTrue(mockView.displayDateCalled)
        XCTAssertNil(mockView.lastDisplayedTitle)
        XCTAssertNil(mockView.lastDisplayedDescription)
        XCTAssertNotNil(mockView.lastDisplayedDate)
    }

    func testViewDidLoad_WithExistingTask_DisplaysTaskData() {
        let task = Task(
            id: UUID(),
            title: "Test Task",
            description: "Test Description",
            isCompleted: false,
            createdAt: Date(timeIntervalSince1970: 1704067200)
        )
        sut.task = task

        sut.viewDidLoad()

        XCTAssertTrue(mockView.setupInitialStateCalled)
        XCTAssertTrue(mockView.displayTaskCalled)
        XCTAssertTrue(mockView.displayDateCalled)
        XCTAssertEqual(mockView.lastDisplayedTitle, "Test Task")
        XCTAssertEqual(mockView.lastDisplayedDescription, "Test Description")
        XCTAssertEqual(mockView.lastDisplayedDate, "01/01/24")
    }

    func testViewDidLoad_WithTaskWithoutDescription_DisplaysNilDescription() {
        let task = Task(
            id: UUID(),
            title: "Test Task",
            description: nil,
            isCompleted: false,
            createdAt: Date()
        )
        sut.task = task

        sut.viewDidLoad()

        XCTAssertTrue(mockView.displayTaskCalled)
        XCTAssertEqual(mockView.lastDisplayedTitle, "Test Task")
        XCTAssertNil(mockView.lastDisplayedDescription)
    }

    // MARK: - Create Task Tests

    func testDidTapSave_WithValidTitle_CreatesNewTask() {
        sut.task = nil

        sut.didTapSave(title: "New Task", description: "New Description")

        XCTAssertTrue(mockInteractor.createTaskCalled)
        XCTAssertEqual(mockInteractor.lastCreatedTitle, "New Task")
        XCTAssertEqual(mockInteractor.lastCreatedDescription, "New Description")
    }

    func testDidTapSave_WithTitleWhitespace_TrimsAndCreates() {
        sut.task = nil

        sut.didTapSave(title: "  Task with spaces  ", description: "  Description with spaces  ")

        XCTAssertTrue(mockInteractor.createTaskCalled)
        XCTAssertEqual(mockInteractor.lastCreatedTitle, "Task with spaces")
        XCTAssertEqual(mockInteractor.lastCreatedDescription, "Description with spaces")
    }

    func testDidTapSave_WithEmptyTitle_DoesNotCreateTask() {
        sut.task = nil

        sut.didTapSave(title: "   ", description: "Description")

        XCTAssertFalse(mockInteractor.createTaskCalled)
    }

    // MARK: - Update Task Tests

    func testDidTapSave_WithExistingTask_UpdatesTask() {
        let existingTask = Task(
            id: UUID(),
            title: "Old Title",
            description: "Old Description",
            isCompleted: false,
            createdAt: Date()
        )
        sut.task = existingTask

        sut.didTapSave(title: "Updated Title", description: "Updated Description")

        XCTAssertTrue(mockInteractor.updateTaskCalled)
        XCTAssertEqual(mockInteractor.lastUpdatedTask?.id, existingTask.id)
        XCTAssertEqual(mockInteractor.lastUpdatedTitle, "Updated Title")
        XCTAssertEqual(mockInteractor.lastUpdatedDescription, "Updated Description")
    }

    func testDidTapSave_WithExistingTaskAndWhitespace_TrimsAndUpdates() {
        let existingTask = Task(
            id: UUID(),
            title: "Old Title",
            description: nil,
            isCompleted: false,
            createdAt: Date()
        )
        sut.task = existingTask

        sut.didTapSave(title: "  New Title  ", description: "  New Description  ")

        XCTAssertTrue(mockInteractor.updateTaskCalled)
        XCTAssertEqual(mockInteractor.lastUpdatedTitle, "New Title")
        XCTAssertEqual(mockInteractor.lastUpdatedDescription, "New Description")
    }

    func testDidTapSave_WithExistingTaskAndEmptyTitle_DoesNotUpdate() {
        let existingTask = Task(
            id: UUID(),
            title: "Old Title",
            description: nil,
            isCompleted: false,
            createdAt: Date()
        )
        sut.task = existingTask

        sut.didTapSave(title: "   ", description: "Description")

        XCTAssertFalse(mockInteractor.updateTaskCalled)
    }

    // MARK: - Interactor Output Tests

    func testDidCreateTask_UpdatesTaskAndPostsNotification() {
        let newTask = Task(
            id: UUID(),
            title: "Created Task",
            description: nil,
            isCompleted: false,
            createdAt: Date()
        )

        let expectation = XCTestExpectation(description: "Notification posted")
        let observer = NotificationCenter.default.addObserver(
            forName: .dataDidLoad,
            object: nil,
            queue: .main
        ) { _ in
            expectation.fulfill()
        }

        sut.didCreateTask(newTask)

        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(sut.task?.id, newTask.id)
        XCTAssertEqual(sut.task?.title, "Created Task")

        NotificationCenter.default.removeObserver(observer)
    }

    func testDidUpdateTask_UpdatesTaskAndPostsNotification() {
        let updatedTask = Task(
            id: UUID(),
            title: "Updated Task",
            description: "Updated Description",
            isCompleted: true,
            createdAt: Date()
        )

        let expectation = XCTestExpectation(description: "Notification posted")
        let observer = NotificationCenter.default.addObserver(
            forName: .dataDidLoad,
            object: nil,
            queue: .main
        ) { _ in
            expectation.fulfill()
        }

        sut.didUpdateTask(updatedTask)

        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(sut.task?.id, updatedTask.id)
        XCTAssertEqual(sut.task?.title, "Updated Task")

        NotificationCenter.default.removeObserver(observer)
    }

    func testDidFailWithError_ShowsErrorInView() {
        let error = NSError(
            domain: "TestError",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Test error message"]
        )

        sut.didFailWithError(error)

        XCTAssertTrue(mockView.showErrorCalled)
        XCTAssertEqual(mockView.lastErrorMessage, "Test error message")
    }

    // MARK: - Date Formatting Tests

    func testViewDidLoad_FormatsDateCorrectly() {
        let date = Date(timeIntervalSince1970: 1704067200)
        let task = Task(
            id: UUID(),
            title: "Task",
            description: nil,
            isCompleted: false,
            createdAt: date
        )
        sut.task = task

        sut.viewDidLoad()

        XCTAssertEqual(mockView.lastDisplayedDate, "01/01/24")
    }
}