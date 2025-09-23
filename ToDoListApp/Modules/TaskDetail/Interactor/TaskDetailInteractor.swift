//
//  TaskDetailInteractor.swift
//  ToDoListApp
//

import Foundation

final class TaskDetailInteractor {

    // MARK: - Properties

    weak var output: TaskDetailInteractorOutput?
    private let dataManager: TaskDataManagerProtocol

    // MARK: - Init

    init(dataManager: TaskDataManagerProtocol) {
        self.dataManager = dataManager
    }
}

// MARK: - TaskDetailInteractorInput

extension TaskDetailInteractor: TaskDetailInteractorInput {

    func createTask(title: String, description: String) {
        dataManager.createTask(with: title, description: description.isEmpty ? nil : description) { [weak self] result in
            switch result {
            case .success(let task):
                self?.output?.didCreateTask(task)

            case .failure(let error):
                self?.output?.didFailWithError(error)
            }
        }
    }

    func updateTask(_ task: Task, title: String, description: String) {
        // Обновляем существующую задачу
        var updatedTask = task
        updatedTask.title = title
        updatedTask.description = description.isEmpty ? nil : description

        dataManager.updateTask(updatedTask) { [weak self] result in
            switch result {
            case .success(let task):
                self?.output?.didUpdateTask(task)

            case .failure(let error):
                self?.output?.didFailWithError(error)
            }
        }
    }
}