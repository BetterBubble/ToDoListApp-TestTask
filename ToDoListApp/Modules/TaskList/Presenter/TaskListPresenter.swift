
import Foundation

final class TaskListPresenter {
    weak var view: TaskListViewInput?
    var interactor: TaskListInteractorInput
    var router: TaskListRouterInput

    private var tasks: [Task] = []

    init(
        view: TaskListViewInput,
        interactor: TaskListInteractorInput,
        router: TaskListRouterInput
    ) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
}

// MARK: - TaskListViewOutput
extension TaskListPresenter: TaskListViewOutput {
    func viewDidLoad() {
        interactor.fetchTasks()
    }

    func didTapAddTask(with title: String) {
        interactor.createTask(with: title)
    }

    func didSelectTask(at index: Int) {
        guard tasks.indices.contains(index) else { return }
        let task = tasks[index]
        router.navigateToTaskDetail(with: task)
    }
}

// MARK: - TaskListInteractorOutput
extension TaskListPresenter: TaskListInteractorOutput {
    func didFetchTasks(_ tasks: [Task]) {
        self.tasks = tasks
        view?.displayTasks(tasks)
    }

    func didFailToFetchTasks(error: Error) {
        // TODO: Обработка ошибок — позже
        print("Ошибка загрузки задач: \(error.localizedDescription)")
    }
}
