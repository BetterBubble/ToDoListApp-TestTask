//
//  MockTaskRepository.swift
//  ToDoListAppTests
//

import Foundation
@testable import ToDoListApp

final class MockTaskRepository: TaskRepositoryProtocol {

    var fetchAllTasksResult: Result<[Task], Error>?
    var fetchTaskResult: Result<Task?, Error>?
    var createTaskResult: Result<Task, Error>?
    var updateTaskResult: Result<Task, Error>?
    var deleteTaskResult: Result<Void, Error>?
    var deleteAllTasksResult: Result<Void, Error>?
    var searchTasksResult: Result<[Task], Error>?
    var getTasksCountResult: Result<Int, Error>?
    var saveTasksFromAPIResult: Result<Void, Error>?

    var fetchAllTasksCalled = false
    var fetchTaskCalled = false
    var createTaskCalled = false
    var updateTaskCalled = false
    var deleteTaskCalled = false
    var deleteAllTasksCalled = false
    var searchTasksCalled = false
    var getTasksCountCalled = false
    var saveTasksFromAPICalled = false

    var lastCreatedTask: Task?
    var lastUpdatedTask: Task?
    var lastDeletedTaskId: UUID?
    var lastSearchText: String?
    var lastSavedTasks: [Task]?

    func fetchAllTasks(completion: @escaping (Result<[Task], Error>) -> Void) {
        fetchAllTasksCalled = true
        if let result = fetchAllTasksResult {
            completion(result)
        }
    }

    func fetchTask(by id: UUID, completion: @escaping (Result<Task?, Error>) -> Void) {
        fetchTaskCalled = true
        if let result = fetchTaskResult {
            completion(result)
        }
    }

    func createTask(_ task: Task, completion: @escaping (Result<Task, Error>) -> Void) {
        createTaskCalled = true
        lastCreatedTask = task
        if let result = createTaskResult {
            completion(result)
        }
    }

    func updateTask(_ task: Task, completion: @escaping (Result<Task, Error>) -> Void) {
        updateTaskCalled = true
        lastUpdatedTask = task
        if let result = updateTaskResult {
            completion(result)
        }
    }

    func deleteTask(by id: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        deleteTaskCalled = true
        lastDeletedTaskId = id
        if let result = deleteTaskResult {
            completion(result)
        }
    }

    func deleteAllTasks(completion: @escaping (Result<Void, Error>) -> Void) {
        deleteAllTasksCalled = true
        if let result = deleteAllTasksResult {
            completion(result)
        }
    }

    func searchTasks(with searchText: String, completion: @escaping (Result<[Task], Error>) -> Void) {
        searchTasksCalled = true
        lastSearchText = searchText
        if let result = searchTasksResult {
            completion(result)
        }
    }

    func getTasksCount(completion: @escaping (Result<Int, Error>) -> Void) {
        getTasksCountCalled = true
        if let result = getTasksCountResult {
            completion(result)
        }
    }

    func saveTasksFromAPI(_ tasks: [Task], completion: @escaping (Result<Void, Error>) -> Void) {
        saveTasksFromAPICalled = true
        lastSavedTasks = tasks
        if let result = saveTasksFromAPIResult {
            completion(result)
        }
    }
}