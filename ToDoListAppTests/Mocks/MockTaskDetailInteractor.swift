//
//  MockTaskDetailInteractor.swift
//  ToDoListAppTests
//

import Foundation
@testable import ToDoListApp

final class MockTaskDetailInteractor: TaskDetailInteractorInput {

    var createTaskCalled = false
    var updateTaskCalled = false

    var lastCreatedTitle: String?
    var lastCreatedDescription: String?
    var lastUpdatedTask: Task?
    var lastUpdatedTitle: String?
    var lastUpdatedDescription: String?

    func createTask(title: String, description: String) {
        createTaskCalled = true
        lastCreatedTitle = title
        lastCreatedDescription = description
    }

    func updateTask(_ task: Task, title: String, description: String) {
        updateTaskCalled = true
        lastUpdatedTask = task
        lastUpdatedTitle = title
        lastUpdatedDescription = description
    }
}