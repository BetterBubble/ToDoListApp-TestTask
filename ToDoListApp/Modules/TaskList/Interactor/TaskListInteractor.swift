
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

    func deleteTask(with id: UUID) {
        dataManager.deleteTask(by: id) { [weak self] result in
            switch result {
            case .success:
                // После удаления перезагружаем список
                self?.fetchTasks()
            case .failure(let error):
                self?.output?.didFailToFetchTasks(error: error)
            }
        }
    }

    func toggleTaskCompletion(for id: UUID) {
        dataManager.toggleTaskCompletion(for: id) { [weak self] result in
            switch result {
            case .success:
                // После обновления перезагружаем список
                self?.fetchTasks()
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
