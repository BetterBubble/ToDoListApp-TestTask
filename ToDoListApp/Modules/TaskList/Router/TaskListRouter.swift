
import UIKit

final class TaskListRouter {
    weak var viewController: UIViewController?
}

extension TaskListRouter: TaskListRouterInput {
    func navigateToTaskDetail(with task: Task) {
        // Здесь создаётся экран с деталями задачи (пока заглушка)
        let alert = UIAlertController(
            title: "Задача",
            message: "ID: \(task.id)\nНазвание: \(task.title)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "ОК", style: .default))

        viewController?.present(alert, animated: true)
    }
}

// MARK: - Модульная сборка
extension TaskListRouter {
    /// Собирает модуль TaskList с dependency injection
    /// Следует принципу Dependency Inversion (D в SOLID)
    static func assembleModule(
        repository: TaskRepositoryProtocol? = nil,
        dataManager: TaskDataManagerProtocol? = nil
    ) -> UIViewController {
        // Создаем зависимости или используем переданные
        let coreDataStack = CoreDataStack.shared
        let repository = repository ?? CoreDataTaskRepository(coreDataStack: coreDataStack)
        let dataManager = dataManager ?? TaskDataManager(repository: repository)

        // Создаем компоненты VIPER
        let view = TaskListViewController()
        let interactor = TaskListInteractor(dataManager: dataManager)
        let router = TaskListRouter()
        let presenter = TaskListPresenter(view: view, interactor: interactor, router: router)

        // Связываем компоненты
        view.output = presenter
        interactor.output = presenter
        router.viewController = view

        // Инициализируем Core Data при первом запуске
        _ = coreDataStack

        return UINavigationController(rootViewController: view)
    }
}
