//
//  TaskDetailProtocols.swift
//  ToDoListApp
//

import UIKit

// MARK: - View Protocols

protocol TaskDetailViewInput: AnyObject {
    func setupInitialState()
    func displayTask(_ task: Task?)
    func displayDate(_ dateString: String)
    func showLoading()
    func hideLoading()
    func showError(_ message: String)
    func dismissView()
}

protocol TaskDetailViewOutput: AnyObject {
    func viewDidLoad()
    func didTapSave(title: String, description: String)
    func didTapCancel()
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

// MARK: - Router Protocols

protocol TaskDetailRouterInput: AnyObject {
    func dismissModule()
}

// MARK: - Module Builder

protocol TaskDetailModuleInput: AnyObject {
    func configure(with task: Task?)
}