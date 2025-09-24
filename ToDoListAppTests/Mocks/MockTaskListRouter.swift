//
//  MockTaskListRouter.swift
//  ToDoListAppTests
//

import Foundation
@testable import ToDoListApp

final class MockTaskListRouter: TaskListRouterInput {

    var navigateToTaskDetailCalled = false
    var shareTaskCalled = false

    var lastNavigatedTask: Task?
    var lastSharedTask: Task?

    func navigateToTaskDetail(with task: Task?) {
        navigateToTaskDetailCalled = true
        lastNavigatedTask = task
    }

    func shareTask(_ task: Task) {
        shareTaskCalled = true
        lastSharedTask = task
    }
}