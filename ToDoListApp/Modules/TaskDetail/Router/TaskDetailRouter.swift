//
//  TaskDetailRouter.swift
//  ToDoListApp
//

import UIKit

final class TaskDetailRouter {

    // MARK: - Module Assembly

    static func assembleModule(with task: Task? = nil) -> UIViewController {
        let view = TaskDetailViewController()
        let presenter = TaskDetailPresenter()
        let interactor = TaskDetailInteractor(
            dataManager: TaskDataManager(
                repository: CoreDataTaskRepository()
            )
        )

        // View -> Presenter
        view.output = presenter

        // Presenter -> View
        presenter.view = view
        presenter.interactor = interactor
        presenter.task = task

        // Interactor -> Presenter
        interactor.output = presenter

        return view
    }
}