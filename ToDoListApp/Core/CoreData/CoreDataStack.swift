//
//  CoreDataStack.swift
//  ToDoListApp
//

import Foundation
import CoreData

/// Протокол для Core Data стека - абстракция для тестирования
protocol CoreDataStackProtocol {
    var viewContext: NSManagedObjectContext { get }
    func save() throws
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void)
}

/// Основной стек Core Data
/// Следует принципу Single Responsibility - отвечает только за управление Core Data
final class CoreDataStack: CoreDataStackProtocol {

    // MARK: - Singleton
    static let shared = CoreDataStack()

    // MARK: - Properties

    /// Имя модели данных
    private let modelName = "ToDoListModel"

    /// Персистентный контейнер
    private lazy var persistentContainer: NSPersistentContainer = {
        // Явно указываем bundle для поиска модели
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
            fatalError("Не удалось найти модель данных \(modelName)")
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Не удалось создать модель данных из URL: \(modelURL)")
        }

        let container = NSPersistentContainer(name: modelName, managedObjectModel: managedObjectModel)

        // Получаем URL для хранилища
        let storeURL = NSPersistentContainer.defaultDirectoryURL()
            .appendingPathComponent("\(modelName).sqlite")

        // Настройка для легковесной миграции
        let description = NSPersistentStoreDescription(url: storeURL)
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true
        description.type = NSSQLiteStoreType

        // Настройки для оптимизации
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { [weak self] (storeDescription, error) in
            if let error = error as NSError? {
                // В продакшене здесь должен быть более грамотный обработчик ошибок
                print("Ошибка загрузки Core Data: \(error), \(error.userInfo)")
                fatalError("Не удалось загрузить хранилище Core Data: \(error)")
            }

            print("Core Data загружена успешно")
            print("Путь к хранилищу: \(storeDescription.url?.absoluteString ?? "неизвестно")")

            // Настройка автоматического слияния изменений
            container.viewContext.automaticallyMergesChangesFromParent = true

            // Первоначальная проверка миграции
            self?.checkFirstLaunch()
        }

        return container
    }()

    /// Основной контекст для UI
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: - Init

    private init() {}

    // MARK: - Public Methods

    /// Сохраняет контекст если есть изменения
    func save() throws {
        let context = viewContext

        guard context.hasChanges else {
            print("Нет изменений для сохранения")
            return
        }

        do {
            try context.save()
            print("Контекст успешно сохранен")
        } catch {
            // Откат изменений при ошибке
            context.rollback()
            print("Ошибка сохранения контекста: \(error)")
            throw CoreDataError.saveFailed(error)
        }
    }

    /// Выполняет операцию в фоновом контексте
    /// - Parameter block: Блок для выполнения в фоновом потоке
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }

    // MARK: - Private Methods

    // Проверяет первый запуск для загрузки данных из API
    private func checkFirstLaunch() {
        let userDefaults = UserDefaults.standard
        let isFirstLaunch = !userDefaults.bool(forKey: "HasLaunchedBefore")

        print("Проверка первого запуска: \(isFirstLaunch ? "ДА" : "НЕТ")")

        if isFirstLaunch {
            userDefaults.set(true, forKey: "HasLaunchedBefore")
            print("Отправляем уведомление для загрузки данных из API")
            // Здесь будет вызов загрузки данных из API
            NotificationCenter.default.post(
                name: .shouldLoadInitialData,
                object: nil
            )
        }
    }
}

// MARK: - Errors

enum CoreDataError: LocalizedError {
    case saveFailed(Error)
    case fetchFailed(Error)
    case entityNotFound

    var errorDescription: String? {
        switch self {
        case .saveFailed(let error):
            return "Не удалось сохранить данные: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Не удалось загрузить данные: \(error.localizedDescription)"
        case .entityNotFound:
            return "Объект не найден"
        }
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let shouldLoadInitialData = Notification.Name("shouldLoadInitialData")
}
