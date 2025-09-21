
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
    static func assembleModule() -> UIViewController {
        let view = TaskListViewController()
        let interactor = TaskListInteractor()
        let router = TaskListRouter()
        let presenter = TaskListPresenter(view: view, interactor: interactor, router: router)

        view.output = presenter
        interactor.output = presenter
        router.viewController = view

        return view
    }
}
