
import UIKit

// MARK: - View → Presenter
protocol TaskListViewInput: AnyObject {
    func displayTasks(_ tasks: [Task])
}

protocol TaskListViewOutput: AnyObject {
    func viewDidLoad()
    func didTapAddTask(with title: String)
    func didSelectTask(at index: Int)
}

// MARK: - Presenter → Interactor
protocol TaskListInteractorInput: AnyObject {
    func fetchTasks()
    func createTask(with title: String)
}

// MARK: - Interactor → Presenter
protocol TaskListInteractorOutput: AnyObject {
    func didFetchTasks(_ tasks: [Task])
    func didFailToFetchTasks(error: Error)
}

// MARK: - Presenter → Router
protocol TaskListRouterInput {
    func navigateToTaskDetail(with task: Task)
}
