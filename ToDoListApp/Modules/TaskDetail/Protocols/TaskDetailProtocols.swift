//
//  TaskDetailProtocols.swift
//  ToDoListApp
//

import Foundation

// MARK: - View Protocols

protocol TaskDetailViewInput: AnyObject {
    func setupInitialState()
    func displayTask(title: String?, description: String?)
    func displayDate(_ dateString: String)
    func showError(_ message: String)
}

protocol TaskDetailViewOutput: AnyObject {
    func viewDidLoad()
    func didTapSave(title: String, description: String)
}

// MARK: - Interactor Protocols

protocol TaskDetailInteractorInput: AnyObject {
    func createTask(title: String, description: String)
    func updateTask(_ task: Task, title: String, description: String)
}

protocol TaskDetailInteractorOutput: AnyObject {
    func didCreateTask(_ task: Task)
    func didUpdateTask(_ task: Task)
    func didFailWithError(_ error: Error)
}

// MARK: - Presenter Protocols

protocol TaskDetailPresenterInput: AnyObject {
    var task: Task? { get set }
}


