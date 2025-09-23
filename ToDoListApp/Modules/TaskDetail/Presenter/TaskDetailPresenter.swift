//
//  TaskDetailPresenter.swift
//  ToDoListApp
//

import Foundation

final class TaskDetailPresenter {

    // MARK: - Properties

    weak var view: TaskDetailViewInput?
    var interactor: TaskDetailInteractorInput?
    var router: TaskDetailRouterInput?

    var task: Task?

    private let dateFormatter: DateFormatter

    // MARK: - Init

    init() {
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "dd/MM/yy"
        self.dateFormatter.locale = Locale(identifier: "ru_RU")
    }

    // MARK: - Private Methods

    private func validateInput(title: String, description: String) -> Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedTitle.isEmpty
    }

    private func formatCurrentDate() -> String {
        return dateFormatter.string(from: Date())
    }
}

// MARK: - TaskDetailViewOutput

extension TaskDetailPresenter: TaskDetailViewOutput {

    func viewDidLoad() {
        view?.setupInitialState()

        // Отображаем существующую задачу или текущую дату для новой
        if let task = task {
            view?.displayTask(task)
            view?.displayDate(dateFormatter.string(from: task.createdAt))
        } else {
            view?.displayTask(nil)
            view?.displayDate(formatCurrentDate())
        }
    }

    func didTapSave(title: String, description: String) {
        // Валидация
        guard validateInput(title: title, description: description) else {
            return
        }

        // Обрезаем пробелы
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)

        if let existingTask = task {
            // Редактирование существующей задачи
            var updatedTask = existingTask
            updatedTask.title = trimmedTitle
            updatedTask.description = trimmedDescription.isEmpty ? nil : trimmedDescription

            interactor?.updateTask(updatedTask, title: trimmedTitle, description: trimmedDescription)
        } else {
            // Создание новой задачи
            interactor?.createTask(title: trimmedTitle, description: trimmedDescription)
        }
    }

    func didTapCancel() {
        router?.dismissModule()
    }
}

// MARK: - TaskDetailInteractorOutput

extension TaskDetailPresenter: TaskDetailInteractorOutput {

    func didCreateTask(_ task: Task) {
        // Сохраняем созданную задачу для последующих обновлений
        self.task = task

        // Отправляем уведомление об изменении данных
        NotificationCenter.default.post(
            name: .dataDidLoad,
            object: nil
        )
    }

    func didUpdateTask(_ task: Task) {
        // Обновляем задачу
        self.task = task

        // Отправляем уведомление об изменении данных
        NotificationCenter.default.post(
            name: .dataDidLoad,
            object: nil
        )
    }

    func didFailWithError(_ error: Error) {
        view?.showError(error.localizedDescription)
    }
}

// MARK: - TaskDetailPresenterInput

extension TaskDetailPresenter: TaskDetailPresenterInput {
    // Свойство task уже объявлено выше
}