//
//  TaskListPresenterTests.swift
//  ToDoListAppTests
//

import XCTest
@testable import ToDoListApp

final class TaskListPresenterTests: XCTestCase {

    var sut: TaskListPresenter!
    var mockView: MockTaskListView!
    var mockInteractor: MockTaskListInteractor!
    var mockRouter: MockTaskListRouter!

    override func setUp() {
        super.setUp()
        mockView = MockTaskListView()
        mockInteractor = MockTaskListInteractor()
        mockRouter = MockTaskListRouter()
        sut = TaskListPresenter(
            view: mockView,
            interactor: mockInteractor,
            router: mockRouter
        )
    }

    override func tearDown() {
        sut = nil
        mockView = nil
        mockInteractor = nil
        mockRouter = nil
        super.tearDown()
    }

    // MARK: - View Did Load Tests

    func testViewDidLoad_ShowsLoadingAndFetchesTasks() {
        sut.viewDidLoad()

        XCTAssertTrue(mockView.showLoadingCalled)
        XCTAssertTrue(mockInteractor.fetchTasksCalled)
    }

    // MARK: - Add Task Tests

    func testDidTapAddTask_NavigatesToTaskDetailWithNilTask() {
        sut.didTapAddTask()

        XCTAssertTrue(mockRouter.navigateToTaskDetailCalled)
        XCTAssertNil(mockRouter.lastNavigatedTask)
    }

    // MARK: - Select Task Tests

    func testDidSelectTask_WithValidIndex_NavigatesToTaskDetail() {
        let task = Task(id: UUID(), title: "Task", description: nil, isCompleted: false, createdAt: Date())
        sut.didFetchTasks([task])

        sut.didSelectTask(at: 0)

        XCTAssertTrue(mockRouter.navigateToTaskDetailCalled)
        XCTAssertEqual(mockRouter.lastNavigatedTask?.id, task.id)
    }

    func testDidSelectTask_WithInvalidIndex_DoesNotNavigate() {
        let task = Task(id: UUID(), title: "Task", description: nil, isCompleted: false, createdAt: Date())
        sut.didFetchTasks([task])

        sut.didSelectTask(at: 5)

        XCTAssertFalse(mockRouter.navigateToTaskDetailCalled)
    }

    // MARK: - Delete Task Tests

    func testDidDeleteTask_WithValidIndex_CallsInteractor() {
        let taskId = UUID()
        let task = Task(id: taskId, title: "Task", description: nil, isCompleted: false, createdAt: Date())
        sut.didFetchTasks([task])

        sut.didDeleteTask(at: 0)

        XCTAssertTrue(mockInteractor.deleteTaskCalled)
        XCTAssertEqual(mockInteractor.lastDeletedTaskId, taskId)
    }

    func testDidDeleteTask_WithInvalidIndex_DoesNotCallInteractor() {
        let task = Task(id: UUID(), title: "Task", description: nil, isCompleted: false, createdAt: Date())
        sut.didFetchTasks([task])

        sut.didDeleteTask(at: 5)

        XCTAssertFalse(mockInteractor.deleteTaskCalled)
    }

    // MARK: - Toggle Task Completion Tests

    func testDidToggleTaskCompletion_WithValidIndex_CallsInteractor() {
        let taskId = UUID()
        let task = Task(id: taskId, title: "Task", description: nil, isCompleted: false, createdAt: Date())
        sut.didFetchTasks([task])

        sut.didToggleTaskCompletion(at: 0)

        XCTAssertTrue(mockInteractor.toggleTaskCompletionCalled)
        XCTAssertEqual(mockInteractor.lastToggledTaskId, taskId)
    }

    func testDidToggleTaskCompletion_WithInvalidIndex_DoesNotCallInteractor() {
        let task = Task(id: UUID(), title: "Task", description: nil, isCompleted: false, createdAt: Date())
        sut.didFetchTasks([task])

        sut.didToggleTaskCompletion(at: 5)

        XCTAssertFalse(mockInteractor.toggleTaskCompletionCalled)
    }

    // MARK: - Search Tests

    func testDidChangeSearchText_WithEmptyText_FetchesAllTasks() {
        sut.didChangeSearchText("")

        XCTAssertTrue(mockInteractor.fetchTasksCalled)
        XCTAssertFalse(mockInteractor.searchTasksCalled)
    }

    func testDidChangeSearchText_WithText_CallsSearch() {
        sut.didChangeSearchText("Search text")

        XCTAssertTrue(mockInteractor.searchTasksCalled)
        XCTAssertEqual(mockInteractor.lastSearchText, "Search text")
        XCTAssertFalse(mockInteractor.fetchTasksCalled)
    }

    // MARK: - Edit Task Tests

    func testDidSelectEdit_WithValidIndex_NavigatesToTaskDetail() {
        let task = Task(id: UUID(), title: "Task", description: nil, isCompleted: false, createdAt: Date())
        sut.didFetchTasks([task])

        sut.didSelectEdit(at: 0)

        XCTAssertTrue(mockRouter.navigateToTaskDetailCalled)
        XCTAssertEqual(mockRouter.lastNavigatedTask?.id, task.id)
    }

    func testDidSelectEdit_WithInvalidIndex_DoesNotNavigate() {
        let task = Task(id: UUID(), title: "Task", description: nil, isCompleted: false, createdAt: Date())
        sut.didFetchTasks([task])

        sut.didSelectEdit(at: 5)

        XCTAssertFalse(mockRouter.navigateToTaskDetailCalled)
    }

    // MARK: - Share Task Tests

    func testDidSelectShare_WithValidIndex_CallsRouter() {
        let task = Task(id: UUID(), title: "Task to share", description: nil, isCompleted: false, createdAt: Date())
        sut.didFetchTasks([task])

        sut.didSelectShare(at: 0)

        XCTAssertTrue(mockRouter.shareTaskCalled)
        XCTAssertEqual(mockRouter.lastSharedTask?.id, task.id)
    }

    func testDidSelectShare_WithInvalidIndex_DoesNotCallRouter() {
        let task = Task(id: UUID(), title: "Task", description: nil, isCompleted: false, createdAt: Date())
        sut.didFetchTasks([task])

        sut.didSelectShare(at: 5)

        XCTAssertFalse(mockRouter.shareTaskCalled)
    }

    // MARK: - Interactor Output Tests

    func testDidFetchTasks_UpdatesViewWithTasks() {
        let tasks = [
            Task(id: UUID(), title: "Task 1", description: nil, isCompleted: false, createdAt: Date()),
            Task(id: UUID(), title: "Task 2", description: nil, isCompleted: true, createdAt: Date())
        ]

        sut.didFetchTasks(tasks)

        XCTAssertTrue(mockView.hideLoadingCalled)
        XCTAssertTrue(mockView.displayTasksCalled)
        XCTAssertEqual(mockView.lastDisplayedTasks?.count, 2)
        XCTAssertEqual(mockView.lastDisplayedTasks?.first?.title, "Task 1")
    }

    func testDidFailToFetchTasks_ShowsError() {
        let error = NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Test error message"])

        sut.didFailToFetchTasks(error: error)

        XCTAssertTrue(mockView.hideLoadingCalled)
        XCTAssertTrue(mockView.showErrorCalled)
        XCTAssertEqual(mockView.lastErrorMessage, "Test error message")
    }

    // MARK: - Date Formatting Tests

    func testGetFormattedDate_WithValidIndex_ReturnsFormattedDate() {
        let date = Date(timeIntervalSince1970: 1704067200)
        let task = Task(id: UUID(), title: "Task", description: nil, isCompleted: false, createdAt: date)
        sut.didFetchTasks([task])

        let formattedDate = sut.getFormattedDate(at: 0)

        XCTAssertEqual(formattedDate, "01/01/24")
    }

    func testGetFormattedDate_WithInvalidIndex_ReturnsEmptyString() {
        let task = Task(id: UUID(), title: "Task", description: nil, isCompleted: false, createdAt: Date())
        sut.didFetchTasks([task])

        let formattedDate = sut.getFormattedDate(at: 5)

        XCTAssertEqual(formattedDate, "")
    }

    // MARK: - Notification Tests

    func testHandleDataDidLoad_FetchesTasks() {
        NotificationCenter.default.post(name: .dataDidLoad, object: nil)

        let expectation = XCTestExpectation(description: "Wait for notification")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)

        XCTAssertTrue(mockInteractor.fetchTasksCalled)
    }
}