
import UIKit

// MARK: - View → Presenter
protocol TaskListViewInput: AnyObject {
    func displayTasks(_ tasks: [Task])
    func showError(_ message: String)
    func showLoading()
    func hideLoading()
}

protocol TaskListViewOutput: AnyObject {
    func viewDidLoad()
    func didTapAddTask(with title: String)
    func didSelectTask(at index: Int)
    func didDeleteTask(at index: Int)
    func didToggleTaskCompletion(at index: Int)
    func didChangeSearchText(_ searchText: String)

    // Методы для получения данных для отображения
    func getTask(at index: Int) -> Task?
    func getFormattedDate(for task: Task) -> String
}

// MARK: - Presenter → Interactor
protocol TaskListInteractorInput: AnyObject {
    func fetchTasks()
    func createTask(with title: String)
    func deleteTask(at index: Int)
    func toggleTaskCompletion(at index: Int)
    func searchTasks(with searchText: String)
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
