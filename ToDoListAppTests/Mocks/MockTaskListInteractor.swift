//
//  MockTaskListInteractor.swift
//  ToDoListAppTests
//

import Foundation
@testable import ToDoListApp

final class MockTaskListInteractor: TaskListInteractorInput {

    var fetchTasksCalled = false
    var deleteTaskCalled = false
    var toggleTaskCompletionCalled = false
    var searchTasksCalled = false

    var lastDeletedTaskId: UUID?
    var lastToggledTaskId: UUID?
    var lastSearchText: String?

    func fetchTasks() {
        fetchTasksCalled = true
    }

    func deleteTask(with id: UUID) {
        deleteTaskCalled = true
        lastDeletedTaskId = id
    }

    func toggleTaskCompletion(for id: UUID) {
        toggleTaskCompletionCalled = true
        lastToggledTaskId = id
    }

    func searchTasks(with searchText: String) {
        searchTasksCalled = true
        lastSearchText = searchText
    }
}