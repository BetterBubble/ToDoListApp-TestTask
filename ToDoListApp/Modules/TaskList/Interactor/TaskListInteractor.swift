
import Foundation

final class TaskListInteractor {
    weak var output: TaskListInteractorOutput?

    // Временно будем хранить задачи в памяти
    private var tasks: [Task] = []
}

// MARK: - TaskListInteractorInput
extension TaskListInteractor: TaskListInteractorInput {
    func fetchTasks() {
        // Заглушка: возвращаем моковые задачи через 0.5 секунды
        let workItem = DispatchWorkItem {
            let mockTasks: [Task] = [
                Task(id: UUID(), title: "Купить молоко", isCompleted: false),
                Task(id: UUID(), title: "Сделать тестовое", isCompleted: true),
                Task(id: UUID(), title: "Записаться в спортзал", isCompleted: false)
            ]

            DispatchQueue.main.async {
                self.output?.didFetchTasks(mockTasks)
            }
        }

        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }

    func createTask(with title: String) {
        let newTask = Task(title: title)
        tasks.append(newTask)
        output?.didFetchTasks(tasks)
    }
}
