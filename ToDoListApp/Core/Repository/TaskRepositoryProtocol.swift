//
//  TaskRepositoryProtocol.swift
//  ToDoListApp
//

import Foundation

/// Протокол репозитория для работы с задачами
/// Абстракция позволяет легко заменить реализацию (CoreData на Realm, например)
/// Следует принципу Dependency Inversion (D в SOLID)
protocol TaskRepositoryProtocol {

    /// Получает все задачи
    /// - Parameter completion: Блок завершения с результатом
    func fetchAllTasks(completion: @escaping (Result<[Task], Error>) -> Void)

    /// Получает задачу по ID
    /// - Parameters:
    ///   - id: Идентификатор задачи
    ///   - completion: Блок завершения с результатом
    func fetchTask(by id: UUID, completion: @escaping (Result<Task?, Error>) -> Void)

    /// Создает новую задачу
    /// - Parameters:
    ///   - task: Модель задачи для создания
    ///   - completion: Блок завершения с результатом
    func createTask(_ task: Task, completion: @escaping (Result<Task, Error>) -> Void)

    /// Обновляет существующую задачу
    /// - Parameters:
    ///   - task: Модель задачи с обновленными данными
    ///   - completion: Блок завершения с результатом
    func updateTask(_ task: Task, completion: @escaping (Result<Task, Error>) -> Void)

    /// Удаляет задачу
    /// - Parameters:
    ///   - id: Идентификатор задачи для удаления
    ///   - completion: Блок завершения с результатом
    func deleteTask(by id: UUID, completion: @escaping (Result<Void, Error>) -> Void)

    /// Удаляет все задачи
    /// - Parameter completion: Блок завершения с результатом
    func deleteAllTasks(completion: @escaping (Result<Void, Error>) -> Void)

    /// Ищет задачи по тексту
    /// - Parameters:
    ///   - searchText: Текст для поиска
    ///   - completion: Блок завершения с результатом
    func searchTasks(with searchText: String, completion: @escaping (Result<[Task], Error>) -> Void)

    /// Получает количество задач
    /// - Parameter completion: Блок завершения с результатом
    func getTasksCount(completion: @escaping (Result<Int, Error>) -> Void)

    /// Сохраняет задачи из API (для первичной загрузки)
    /// - Parameters:
    ///   - tasks: Массив задач для сохранения
    ///   - completion: Блок завершения с результатом
    func saveTasksFromAPI(_ tasks: [Task], completion: @escaping (Result<Void, Error>) -> Void)
}