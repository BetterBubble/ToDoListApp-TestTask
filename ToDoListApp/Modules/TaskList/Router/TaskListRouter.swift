
import UIKit

final class TaskListRouter {
    weak var viewController: UIViewController?
}

extension TaskListRouter: TaskListRouterInput {
    func navigateToTaskDetail(with task: Task?) {
        let taskDetailViewController = TaskDetailRouter.assembleModule(with: task)
        viewController?.navigationController?.pushViewController(taskDetailViewController, animated: true)
    }

    func shareTask(_ task: Task) {
        guard let viewController = self.viewController else { return }

        var textToShare = task.title

        if let description = task.description, !description.isEmpty {
            textToShare += "\n\n\(description)"
        }

        let activityViewController = UIActivityViewController(
            activityItems: [textToShare],
            applicationActivities: nil
        )

        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = viewController.view
            popoverController.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        viewController.present(activityViewController, animated: true)
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
