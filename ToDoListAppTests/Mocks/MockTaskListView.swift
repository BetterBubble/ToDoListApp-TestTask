//
//  MockTaskListView.swift
//  ToDoListAppTests
//

import Foundation
@testable import ToDoListApp

final class MockTaskListView: TaskListViewInput {

    var displayTasksCalled = false
    var showErrorCalled = false
    var showLoadingCalled = false
    var hideLoadingCalled = false

    var lastDisplayedTasks: [Task]?
    var lastErrorMessage: String?

    func displayTasks(_ tasks: [Task]) {
        displayTasksCalled = true
        lastDisplayedTasks = tasks
    }

    func showError(_ message: String) {
        showErrorCalled = true
        lastErrorMessage = message
    }

    func showLoading() {
        showLoadingCalled = true
    }

    func hideLoading() {
        hideLoadingCalled = true
    }
}