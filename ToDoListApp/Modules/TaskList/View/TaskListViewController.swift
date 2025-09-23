
import UIKit

final class TaskListViewController: UIViewController {

    // MARK: - VIPER Output
    var output: TaskListViewOutput?

    // MARK: - UI
    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private var tasks: [Task] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        output?.viewDidLoad() // Сообщаем Presenter'у, что вью загрузилась
    }

    // MARK: - UI Setup
    private func setupUI() {
        title = "Задачи"
        view.backgroundColor = .systemBackground

        // Настройка навигации
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTaskTapped)
        )

        // Настройка поиска
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск задач"
        navigationItem.searchController = searchController
        definesPresentationContext = true

        // Настройка таблицы
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TaskCell")

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        // Настройка индикатора загрузки
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Actions
    @objc private func addTaskTapped() {
        let alert = UIAlertController(
            title: "Новая задача",
            message: "Введите описание задачи",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "Описание задачи"
        }

        let addAction = UIAlertAction(title: "Добавить", style: .default) { [weak self] _ in
            guard let description = alert.textFields?.first?.text else { return }
            // Передаём описание, номер задачи сгенерируется автоматически
            self?.output?.didTapAddTask(with: description)
        }

        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))

        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = tasks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)

        var content = cell.defaultContentConfiguration()

        // Основной текст - название задачи (например: "Задача 1")
        content.text = task.title

        // Вторичный текст - описание и дата
        var secondaryText = ""

        // Сначала добавляем описание (если есть)
        if let description = task.description, !description.isEmpty {
            secondaryText = description
        }

        // Добавляем дату создания
        let formattedDate = output?.getFormattedDate(for: task) ?? ""
        if !secondaryText.isEmpty {
            secondaryText += "\n"
        }
        secondaryText += formattedDate

        content.secondaryText = secondaryText
        content.secondaryTextProperties.numberOfLines = 3
        content.secondaryTextProperties.color = .secondaryLabel

        cell.contentConfiguration = content
        // Галочка справа показывает статус выполнения
        cell.accessoryType = task.isCompleted ? .checkmark : .none

        return cell
    }

    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let toggleAction = UIContextualAction(style: .normal, title: "Статус") { [weak self] _, _, completion in
            self?.output?.didToggleTaskCompletion(at: indexPath.row)
            completion(true)
        }
        toggleAction.backgroundColor = .systemBlue

        return UISwipeActionsConfiguration(actions: [toggleAction])
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, completion in
            self?.output?.didDeleteTask(at: indexPath.row)
            completion(true)
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// MARK: - UITableViewDelegate
extension TaskListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        output?.didSelectTask(at: indexPath.row)
    }
}

// MARK: - TaskListViewInput
extension TaskListViewController: TaskListViewInput {

    func displayTasks(_ tasks: [Task]) {
        self.tasks = tasks
        tableView.reloadData()
    }

    func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }

    func showLoading() {
        activityIndicator.startAnimating()
        tableView.isHidden = true
    }

    func hideLoading() {
        activityIndicator.stopAnimating()
        tableView.isHidden = false
    }
}

// MARK: - UISearchResultsUpdating
extension TaskListViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        output?.didChangeSearchText(searchText)
    }
}
