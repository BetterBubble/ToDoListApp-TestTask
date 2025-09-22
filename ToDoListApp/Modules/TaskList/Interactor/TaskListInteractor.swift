
import Foundation

/// Интерактор модуля TaskList
/// Отвечает за бизнес-логику и работу с данными
/// Следует принципу Single Responsibility (S в SOLID)
final class TaskListInteractor {

    // MARK: - Properties

    weak var output: TaskListInteractorOutput?
    private let dataManager: TaskDataManagerProtocol

    // MARK: - Init

    init(dataManager: TaskDataManagerProtocol) {
        self.dataManager = dataManager
    }
}

// MARK: - TaskListInteractorInput

extension TaskListInteractor: TaskListInteractorInput {

    func fetchTasks() {
        // Загружаем задачи через DataManager
        dataManager.fetchAllTasks { [weak self] result in
            switch result {
            case .success(let tasks):
                self?.output?.didFetchTasks(tasks)
            case .failure(let error):
                self?.output?.didFailToFetchTasks(error: error)
            }
        }
    }

    func createTask(with title: String) {
        // Создаем задачу через DataManager
        dataManager.createTask(with: title, description: nil) { [weak self] result in
            switch result {
            case .success:
                // После создания перезагружаем список
                self?.fetchTasks()
            case .failure(let error):
                self?.output?.didFailToFetchTasks(error: error)
            }
        }
    }

    func deleteTask(at index: Int) {
        // Сначала получаем все задачи, чтобы найти нужную по индексу
        dataManager.fetchAllTasks { [weak self] result in
            switch result {
            case .success(let tasks):
                guard tasks.indices.contains(index) else { return }
                let taskToDelete = tasks[index]

                self?.dataManager.deleteTask(by: taskToDelete.id) { deleteResult in
                    switch deleteResult {
                    case .success:
                        // После удаления перезагружаем список
                        self?.fetchTasks()
                    case .failure(let error):
                        self?.output?.didFailToFetchTasks(error: error)
                    }
                }
            case .failure(let error):
                self?.output?.didFailToFetchTasks(error: error)
            }
        }
    }

    func toggleTaskCompletion(at index: Int) {
        // Получаем все задачи и переключаем статус нужной
        dataManager.fetchAllTasks { [weak self] result in
            switch result {
            case .success(let tasks):
                guard tasks.indices.contains(index) else { return }
                let task = tasks[index]

                self?.dataManager.toggleTaskCompletion(for: task.id) { toggleResult in
                    switch toggleResult {
                    case .success:
                        // После обновления перезагружаем список
                        self?.fetchTasks()
                    case .failure(let error):
                        self?.output?.didFailToFetchTasks(error: error)
                    }
                }
            case .failure(let error):
                self?.output?.didFailToFetchTasks(error: error)
            }
        }
    }

    func searchTasks(with searchText: String) {
        dataManager.searchTasks(with: searchText) { [weak self] result in
            switch result {
            case .success(let tasks):
                self?.output?.didFetchTasks(tasks)
            case .failure(let error):
                self?.output?.didFailToFetchTasks(error: error)
            }
        }
    }
}
