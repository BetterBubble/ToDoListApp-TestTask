//
//  AppDelegate.swift
//  ToDoListApp
//
//  Created by Александр Шульга on 20.09.2025.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Properties

    /// Сервис миграции данных
    private var dataMigrationService: DataMigrationService?

    // MARK: - UIApplicationDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // ОТЛАДКА: Раскомментируйте для полного сброса данных и повторной загрузки из API
        // CoreDataStack.deleteAllData()

        // Показываем путь к базе данных
        let storeURL = NSPersistentContainer.defaultDirectoryURL()
            .appendingPathComponent("ToDoListModel.sqlite")
        print("Путь к базе данных: \(storeURL.path)")

        // Инициализируем сервис миграции данных
        dataMigrationService = DataMigrationService()

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

