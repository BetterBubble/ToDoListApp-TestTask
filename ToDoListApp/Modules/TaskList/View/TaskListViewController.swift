import UIKit

/// View компонент модуля TaskList в VIPER архитектуре
/// Отвечает только за отображение UI и передачу событий в Presenter
/// Следует принципу Single Responsibility (S в SOLID)
final class TaskListViewController: UIViewController {

    // MARK: - VIPER Properties

    var output: TaskListViewOutput?

    // MARK: - UI Elements

    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    private let floatingButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false

        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        button.setImage(UIImage(systemName: "square.and.pencil", withConfiguration: config), for: .normal)
        button.tintColor = UIColor(named: "AccentYellow")

        return button
    }()

    private let bottomToolbar: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "BackgroundDarkGray")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let taskCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.textColor = UIColor(named: "TextPrimary") ?? .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Private Properties

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        output?.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Устанавливаем цвет курсора
        searchBar.searchTextField.tintColor = UIColor(named: "AccentYellow")

        // Устанавливаем цвет иконки поиска с использованием alwaysOriginal
        if let searchIconView = searchBar.searchTextField.leftView as? UIImageView {
            let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
            let searchIcon = UIImage(systemName: "magnifyingglass", withConfiguration: config)?.withTintColor(UIColor(named: "TextSecondary") ?? .gray, renderingMode: .alwaysOriginal)
            searchIconView.image = searchIcon
        }

        // Добавляем микрофон после полной загрузки view
        setupSearchBarMicrophone()
    }

    // MARK: - Setup Methods

    private func setupUI() {
        view.backgroundColor = UIColor(named: "BackgroundPrimary")

        setupNavigationBar()
        setupSearchBar()
        setupTableView()
        setupBottomToolbar()
        setupActivityIndicator()
        setupConstraints()
    }

    private func setupNavigationBar() {
        // Создаем label для заголовка
        let titleLabel = UILabel()
        titleLabel.text = "Задачи"
        titleLabel.font = .systemFont(ofSize: 34, weight: .bold)
        titleLabel.textColor = UIColor(named: "TextPrimary")
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)

        // Настройка навигационной панели
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor(named: "BackgroundPrimary")
        navigationController?.navigationBar.tintColor = UIColor(named: "TextPrimary")
    }

    private func setupSearchBar() {
        // Основные настройки
        searchBar.placeholder = "Поиск"
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false

        // Отключаем системные кнопки, которые могут мешать
        searchBar.showsCancelButton = false
        searchBar.showsBookmarkButton = false

        // Цветовая схема
        searchBar.barTintColor = UIColor(named: "BackgroundDarkGray")
        searchBar.searchTextField.backgroundColor = UIColor(named: "BackgroundDarkGray")
        searchBar.searchTextField.textColor = UIColor(named: "TextPrimary")

        // Отключаем кнопку очистки, чтобы она не конфликтовала с микрофоном
        searchBar.searchTextField.clearButtonMode = .never

        // Placeholder
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search",
            attributes: [.foregroundColor: UIColor(named: "TextSecondary") ?? .gray]
        )

        // Добавляем на экран
        view.addSubview(searchBar)
    }

    private func setupSearchBarMicrophone() {
        // Проверяем, что searchBar уже в иерархии
        guard searchBar.superview != nil else {
            return
        }

        // Создаем контейнер для микрофона с правильными отступами
        let rightContainer = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))

        // Создаем иконку микрофона (сдвигаем правее)
        let micImageView = UIImageView(frame: CGRect(x: 20, y: 5, width: 20, height: 20))
        let micConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        let micImage = UIImage(systemName: "mic.fill", withConfiguration: micConfig)?.withTintColor(UIColor(named: "TextSecondary") ?? .gray, renderingMode: .alwaysOriginal)
        micImageView.image = micImage
        micImageView.contentMode = .scaleAspectFit

        // Добавляем микрофон в контейнер
        rightContainer.addSubview(micImageView)

        // Устанавливаем как rightView
        searchBar.searchTextField.rightView = rightContainer
        searchBar.searchTextField.rightViewMode = .always

        // Обновляем layout
        DispatchQueue.main.async { [weak self] in
            self?.searchBar.searchTextField.setNeedsLayout()
            self?.searchBar.searchTextField.layoutIfNeeded()
        }
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: TaskTableViewCell.identifier)
        tableView.backgroundColor = UIColor(named: "BackgroundPrimary")
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.keyboardDismissMode = .onDrag

        view.addSubview(tableView)

        // Добавляем жест для скрытия клавиатуры при нажатии на экран
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    private func setupBottomToolbar() {
        // Добавляем toolbar
        view.addSubview(bottomToolbar)

        // Добавляем счетчик задач
        bottomToolbar.addSubview(taskCountLabel)
        updateTaskCount()

        // Добавляем кнопку создания
        bottomToolbar.addSubview(floatingButton)
        floatingButton.addTarget(self, action: #selector(addTaskTapped), for: .touchUpInside)
    }

    private func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor(named: "AccentYellow")
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(activityIndicator)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Search Bar
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 52),

            // Table View
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomToolbar.topAnchor),

            // Bottom Toolbar
            bottomToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomToolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomToolbar.heightAnchor.constraint(equalToConstant: 83),

            // Task Count Label
            taskCountLabel.centerXAnchor.constraint(equalTo: bottomToolbar.centerXAnchor),
            taskCountLabel.centerYAnchor.constraint(equalTo: floatingButton.centerYAnchor),

            // Floating Button
            floatingButton.trailingAnchor.constraint(equalTo: bottomToolbar.trailingAnchor, constant: -16),
            floatingButton.centerYAnchor.constraint(equalTo: bottomToolbar.centerYAnchor, constant: -10),
            floatingButton.widthAnchor.constraint(equalToConstant: 56),
            floatingButton.heightAnchor.constraint(equalToConstant: 56),

            // Activity Indicator
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Private Methods

    private func updateTaskCount() {
        taskCountLabel.text = output?.getTasksCount()
    }

    // MARK: - Actions

    @objc private func addTaskTapped() {
        output?.didTapAddTask()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - TaskListViewInput

extension TaskListViewController: TaskListViewInput {

    func displayTasks(_ tasks: [Task]) {
        updateTaskCount()
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

// MARK: - UITableViewDataSource

extension TaskListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return output?.getNumberOfTasks() ?? 0
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TaskTableViewCell.identifier,
            for: indexPath
        ) as? TaskTableViewCell,
              let output = output else {
            return UITableViewCell()
        }

        cell.configure(
            title: output.getCellTitle(at: indexPath.row),
            description: output.getCellDescription(at: indexPath.row),
            dateString: output.getFormattedDate(at: indexPath.row),
            isCompleted: output.isCellCompleted(at: indexPath.row),
            isDescriptionEmpty: output.isCellDescriptionEmpty(at: indexPath.row)
        )

        // Устанавливаем замыкание для нажатия на индикатор
        cell.onCompletionToggle = { [weak self] in
            self?.output?.didToggleTaskCompletion(at: indexPath.row)
        }

        return cell
    }

    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let task = output?.getTask(at: indexPath.row) else { return nil }
        let title = task.isCompleted ? "Не выполнено" : "Выполнено"

        let toggleAction = UIContextualAction(style: .normal, title: title) { [weak self] _, _, completion in
            self?.output?.didToggleTaskCompletion(at: indexPath.row)
            completion(true)
        }
        toggleAction.backgroundColor = UIColor(named: "AccentYellow")

        return UISwipeActionsConfiguration(actions: [toggleAction])
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, completion in
            self?.output?.didDeleteTask(at: indexPath.row)
            completion(true)
        }
        deleteAction.backgroundColor = UIColor.systemRed

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

// MARK: - UITableViewDelegate

extension TaskListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        output?.didSelectTask(at: indexPath.row)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }

    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { [weak self] _ in
            let editAction = UIAction(
                title: "Редактировать",
                image: UIImage(named: "IconEdit")
            ) { _ in
                self?.output?.didSelectEdit(at: indexPath.row)
            }

            let shareAction = UIAction(
                title: "Поделиться",
                image: UIImage(named: "IconExport")
            ) { _ in
                self?.output?.didSelectShare(at: indexPath.row)
            }

            let deleteAction = UIAction(
                title: "Удалить",
                image: UIImage(named: "IconDelete"),
                attributes: .destructive
            ) { _ in
                self?.output?.didDeleteTask(at: indexPath.row)
            }

            return UIMenu(title: "", children: [editAction, shareAction, deleteAction])
        }
    }

    func tableView(_ tableView: UITableView,
                   previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? NSIndexPath,
              let cell = tableView.cellForRow(at: indexPath as IndexPath) else {
            return nil
        }

        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear

        return UITargetedPreview(view: cell, parameters: parameters)
    }
}

// MARK: - UISearchBarDelegate

extension TaskListViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        output?.didChangeSearchText(searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

