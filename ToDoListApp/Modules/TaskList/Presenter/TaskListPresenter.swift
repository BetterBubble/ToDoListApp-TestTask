
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

        // Подписываемся на уведомление о загрузке данных из API
        setupNotificationObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Private Methods

    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDataDidLoad),
            name: .dataDidLoad,
            object: nil
        )
    }

    @objc private func handleDataDidLoad() {
        print("Presenter: Получено уведомление о загрузке данных из API")
        interactor.fetchTasks()
    }
}

// MARK: - TaskListViewOutput
extension TaskListPresenter: TaskListViewOutput {
    func viewDidLoad() {
        view?.showLoading()
        interactor.fetchTasks()
    }

    func didTapAddTask(with title: String) {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            view?.showError("Название задачи не может быть пустым")
            return
        }
        interactor.createTask(with: title)
    }

    func didSelectTask(at index: Int) {
        guard tasks.indices.contains(index) else { return }
        let task = tasks[index]
        router.navigateToTaskDetail(with: task)
    }

    func didDeleteTask(at index: Int) {
        interactor.deleteTask(at: index)
    }

    func didToggleTaskCompletion(at index: Int) {
        interactor.toggleTaskCompletion(at: index)
    }

    func didChangeSearchText(_ searchText: String) {
        if searchText.isEmpty {
            interactor.fetchTasks()
        } else {
            interactor.searchTasks(with: searchText)
        }
    }
}

// MARK: - TaskListInteractorOutput
extension TaskListPresenter: TaskListInteractorOutput {
    func didFetchTasks(_ tasks: [Task]) {
        self.tasks = tasks
        view?.hideLoading()
        view?.displayTasks(tasks)
    }

    func didFailToFetchTasks(error: Error) {
        view?.hideLoading()
        view?.showError(error.localizedDescription)
    }
}
