
import UIKit

final class TaskListViewController: UIViewController {

    // MARK: - VIPER Output
    var output: TaskListViewOutput?

    // MARK: - UI
    private let tableView = UITableView()
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

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TaskCell")

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
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
        content.text = task.title
        content.secondaryText = task.isCompleted ? "Выполнена" : "В процессе"
        cell.contentConfiguration = content
        return cell
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
}
