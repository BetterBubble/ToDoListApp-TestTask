
import Foundation

final class TaskListPresenter {
    weak var view: TaskListViewInput?
    var interactor: TaskListInteractorInput
    var router: TaskListRouterInput

    private var tasks: [Task] = []
    private let dateFormatter: DateFormatter

    init(
        view: TaskListViewInput,
        interactor: TaskListInteractorInput,
        router: TaskListRouterInput
    ) {
        self.view = view
        self.interactor = interactor
        self.router = router

        // Настройка форматтера даты
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "dd/MM/yy"
        self.dateFormatter.locale = Locale(identifier: "ru_RU")

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

    // MARK: - Public Methods for View

    func getFormattedDate(at index: Int) -> String {
        guard tasks.indices.contains(index) else { return "" }
        return dateFormatter.string(from: tasks[index].createdAt)
    }
}

// MARK: - TaskListViewOutput
extension TaskListPresenter: TaskListViewOutput {
    func viewDidLoad() {
        view?.showLoading()
        interactor.fetchTasks()
    }

    func didTapAddTask() {
        router.navigateToTaskDetail(with: nil)
    }

    func didSelectTask(at index: Int) {
        guard tasks.indices.contains(index) else { return }
        router.navigateToTaskDetail(with: tasks[index])
    }

    func didDeleteTask(at index: Int) {
        guard tasks.indices.contains(index) else { return }
        interactor.deleteTask(with: tasks[index].id)
    }

    func didToggleTaskCompletion(at index: Int) {
        guard tasks.indices.contains(index) else { return }
        interactor.toggleTaskCompletion(for: tasks[index].id)
    }

    func didChangeSearchText(_ searchText: String) {
        if searchText.isEmpty {
            interactor.fetchTasks()
        } else {
            interactor.searchTasks(with: searchText)
        }
    }

    func didSelectEdit(at index: Int) {
        guard tasks.indices.contains(index) else { return }
        router.navigateToTaskDetail(with: tasks[index])
    }

    func didSelectShare(at index: Int) {
        guard tasks.indices.contains(index) else { return }
        router.shareTask(tasks[index])
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
