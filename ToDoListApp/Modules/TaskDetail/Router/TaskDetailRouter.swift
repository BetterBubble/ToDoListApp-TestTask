//
//  TaskDetailRouter.swift
//  ToDoListApp
//

import UIKit

final class TaskDetailRouter {

    // MARK: - Properties

    weak var viewController: UIViewController?

    // MARK: - Module Assembly

    static func assembleModule(with task: Task? = nil) -> UIViewController {
        let view = TaskDetailViewController()
        let presenter = TaskDetailPresenter()
        let interactor = TaskDetailInteractor(
            dataManager: TaskDataManager(
                repository: CoreDataTaskRepository()
            )
        )
        let router = TaskDetailRouter()

        // View -> Presenter
        view.output = presenter

        // Presenter -> View
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        presenter.task = task

        // Interactor -> Presenter
        interactor.output = presenter

        // Router -> View
        router.viewController = view

        return view
    }
}

// MARK: - TaskDetailRouterInput

extension TaskDetailRouter: TaskDetailRouterInput {

    func dismissModule() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}