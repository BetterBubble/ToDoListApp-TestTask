//
//  APIService.swift
//  ToDoListApp
//

import Foundation

/// Модель задачи из API
struct APITask: Codable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}

/// Модель ответа API
struct APIResponse: Codable {
    let todos: [APITask]
    let total: Int
    let skip: Int
    let limit: Int
}

/// Протокол сервиса для работы с API
protocol APIServiceProtocol {
    func fetchTasks(completion: @escaping (Result<[APITask], Error>) -> Void)
}

/// Сервис для работы с DummyJSON API
/// Следует принципу Single Responsibility (S в SOLID)
final class APIService: APIServiceProtocol {

    // MARK: - Properties

    private let baseURL = "https://dummyjson.com"
    private let session: URLSession

    // MARK: - Init

    init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: - APIServiceProtocol

    func fetchTasks(completion: @escaping (Result<[APITask], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/todos") else {
            completion(.failure(APIError.invalidURL))
            return
        }

        let task = session.dataTask(with: url) { data, response, error in
            // Обработка ошибки сети
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(APIError.networkError(error)))
                }
                return
            }

            // Проверка HTTP статуса
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(.failure(APIError.serverError))
                }
                return
            }

            // Проверка наличия данных
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(APIError.noData))
                }
                return
            }

            // Декодирование JSON
            do {
                let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(apiResponse.todos))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(APIError.decodingError(error)))
                }
            }
        }

        task.resume()
    }
}

// MARK: - API Errors

enum APIError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case serverError
    case noData
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Некорректный URL"
        case .networkError(let error):
            return "Ошибка сети: \(error.localizedDescription)"
        case .serverError:
            return "Ошибка сервера"
        case .noData:
            return "Нет данных"
        case .decodingError(let error):
            return "Ошибка декодирования: \(error.localizedDescription)"
        }
    }
}