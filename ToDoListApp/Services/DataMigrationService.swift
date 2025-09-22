//
//  DataMigrationService.swift
//  ToDoListApp
//

import Foundation

/// Сервис миграции данных при первом запуске
/// Отвечает за загрузку начальных данных из API в Core Data
/// Следует принципу Single Responsibility (S в SOLID)
final class DataMigrationService {

    // MARK: - Properties

    private let apiService: APIServiceProtocol
    private let repository: TaskRepositoryProtocol

    // MARK: - Init

    init(
        apiService: APIServiceProtocol = APIService(),
        repository: TaskRepositoryProtocol = CoreDataTaskRepository()
    ) {
        self.apiService = apiService
        self.repository = repository

        // Подписываемся на уведомление о первом запуске
        setupNotificationObserver()
    }

    // MARK: - Private Methods

    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleFirstLaunch),
            name: .shouldLoadInitialData,
            object: nil
        )
    }

    @objc private func handleFirstLaunch() {
        loadInitialDataFromAPI()
    }

    /// Загружает начальные данные из API
    func loadInitialDataFromAPI() {
        print("📥 Начинаем загрузку данных из API...")

        apiService.fetchTasks { [weak self] result in
            switch result {
            case .success(let apiTasks):
                print("✅ Получено \(apiTasks.count) задач из API")
                self?.convertAndSaveTasks(apiTasks)

            case .failure(let error):
                print("❌ Ошибка загрузки из API: \(error.localizedDescription)")
                // В случае ошибки создаем демо-данные
                self?.createDemoTasks()
            }
        }
    }

    /// Конвертирует задачи из API формата в доменную модель и сохраняет
    private func convertAndSaveTasks(_ apiTasks: [APITask]) {
        let domainTasks = apiTasks.map { apiTask in
            Task(
                id: UUID(),
                title: apiTask.todo,
                isCompleted: apiTask.completed,
                createdAt: Date()
            )
        }

        repository.saveTasksFromAPI(domainTasks) { result in
            switch result {
            case .success:
                print("✅ Задачи успешно сохранены в Core Data")
                // Отправляем уведомление об успешной загрузке
                NotificationCenter.default.post(
                    name: .dataDidLoad,
                    object: nil
                )

            case .failure(let error):
                print("❌ Ошибка сохранения в Core Data: \(error.localizedDescription)")
            }
        }
    }

    /// Создает демо-задачи если не удалось загрузить из API
    private func createDemoTasks() {
        let demoTasks = [
            Task(title: "Изучить архитектуру VIPER", isCompleted: false),
            Task(title: "Настроить Core Data", isCompleted: true),
            Task(title: "Реализовать загрузку из API", isCompleted: false),
            Task(title: "Написать юнит-тесты", isCompleted: false),
            Task(title: "Добавить поиск по задачам", isCompleted: false)
        ]

        repository.saveTasksFromAPI(demoTasks) { result in
            switch result {
            case .success:
                print("✅ Демо-задачи созданы")
                NotificationCenter.default.post(
                    name: .dataDidLoad,
                    object: nil
                )

            case .failure(let error):
                print("❌ Не удалось создать демо-задачи: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Deinit

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let dataDidLoad = Notification.Name("dataDidLoad")
}