
import Foundation

// MARK: - View → Presenter
protocol TaskListViewInput: AnyObject {
    func displayTasks(_ tasks: [Task])
    func showError(_ message: String)
    func showLoading()
    func hideLoading()
}

protocol TaskListViewOutput: AnyObject {
    func viewDidLoad()
    func didTapAddTask()
    func didSelectTask(at index: Int)
    func didDeleteTask(at index: Int)
    func didToggleTaskCompletion(at index: Int)
    func didChangeSearchText(_ searchText: String)

    func didSelectEdit(at index: Int)
    func didSelectShare(at index: Int)

    func getFormattedDate(at index: Int) -> String
}

// MARK: - Presenter → Interactor
protocol TaskListInteractorInput: AnyObject {
    func fetchTasks()
    func deleteTask(with id: UUID)
    func toggleTaskCompletion(for id: UUID)
    func searchTasks(with searchText: String)
}

// MARK: - Interactor → Presenter
protocol TaskListInteractorOutput: AnyObject {
    func didFetchTasks(_ tasks: [Task])
    func didFailToFetchTasks(error: Error)
}

// MARK: - Presenter → Router
protocol TaskListRouterInput {
    func navigateToTaskDetail(with task: Task?)
    func shareTask(_ task: Task)
}
