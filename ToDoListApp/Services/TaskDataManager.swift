//
//  TaskDataManager.swift
//  ToDoListApp
//

import Foundation

/// Протокол менеджера данных для работы с задачами
/// Следует принципу Interface Segregation (I в SOLID)
protocol TaskDataManagerProtocol {
    func fetchAllTasks(completion: @escaping (Result<[Task], Error>) -> Void)
    func createTask(with title: String, description: String?, completion: @escaping (Result<Task, Error>) -> Void)
    func updateTask(_ task: Task, completion: @escaping (Result<Task, Error>) -> Void)
    func deleteTask(by id: UUID, completion: @escaping (Result<Void, Error>) -> Void)
    func searchTasks(with searchText: String, completion: @escaping (Result<[Task], Error>) -> Void)
    func toggleTaskCompletion(for taskId: UUID, completion: @escaping (Result<Task, Error>) -> Void)
}

/// Менеджер данных - промежуточный слой между Interactor и Repository
/// Содержит дополнительную бизнес-логику работы с данными
final class TaskDataManager: TaskDataManagerProtocol {

    // MARK: - Properties

    private let repository: TaskRepositoryProtocol

    // MARK: - Init

    init(repository: TaskRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - TaskDataManagerProtocol

    func fetchAllTasks(completion: @escaping (Result<[Task], Error>) -> Void) {
        repository.fetchAllTasks(completion: completion)
    }

    func createTask(with title: String, description: String? = nil, completion: @escaping (Result<Task, Error>) -> Void) {
        // Валидация перед созданием
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            completion(.failure(TaskError.invalidTitle))
            return
        }

        let task = Task(
            id: UUID(),
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            isCompleted: false,
            createdAt: Date()
        )

        repository.createTask(task, completion: completion)
    }

    func updateTask(_ task: Task, completion: @escaping (Result<Task, Error>) -> Void) {
        // Валидация перед обновлением
        guard !task.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            completion(.failure(TaskError.invalidTitle))
            return
        }

        repository.updateTask(task, completion: completion)
    }

    func deleteTask(by id: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        repository.deleteTask(by: id, completion: completion)
    }

    func searchTasks(with searchText: String, completion: @escaping (Result<[Task], Error>) -> Void) {
        let trimmedText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        // Если поиск пустой, возвращаем все задачи
        if trimmedText.isEmpty {
            repository.fetchAllTasks(completion: completion)
        } else {
            repository.searchTasks(with: trimmedText, completion: completion)
        }
    }

    func toggleTaskCompletion(for taskId: UUID, completion: @escaping (Result<Task, Error>) -> Void) {
        repository.fetchTask(by: taskId) { [weak self] result in
            switch result {
            case .success(let task):
                guard var task = task else {
                    completion(.failure(TaskError.taskNotFound))
                    return
                }

                // Переключаем статус выполнения
                task.isCompleted.toggle()

                self?.repository.updateTask(task, completion: completion)

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Errors

enum TaskError: LocalizedError {
    case invalidTitle
    case taskNotFound
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .invalidTitle:
            return "Название задачи не может быть пустым"
        case .taskNotFound:
            return "Задача не найдена"
        case .saveFailed:
            return "Не удалось сохранить задачу"
        }
    }
}