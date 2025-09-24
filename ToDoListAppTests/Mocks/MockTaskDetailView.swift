//
//  MockTaskDetailView.swift
//  ToDoListAppTests
//

import Foundation
@testable import ToDoListApp

final class MockTaskDetailView: TaskDetailViewInput {

    var setupInitialStateCalled = false
    var displayTaskCalled = false
    var displayDateCalled = false
    var showErrorCalled = false

    var lastDisplayedTitle: String?
    var lastDisplayedDescription: String?
    var lastDisplayedDate: String?
    var lastErrorMessage: String?

    func setupInitialState() {
        setupInitialStateCalled = true
    }

    func displayTask(title: String?, description: String?) {
        displayTaskCalled = true
        lastDisplayedTitle = title
        lastDisplayedDescription = description
    }

    func displayDate(_ dateString: String) {
        displayDateCalled = true
        lastDisplayedDate = dateString
    }

    func showError(_ message: String) {
        showErrorCalled = true
        lastErrorMessage = message
    }
}