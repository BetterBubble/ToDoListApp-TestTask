//
//  TaskDetailViewController.swift
//  ToDoListApp
//

import UIKit

final class TaskDetailViewController: UIViewController {

    // MARK: - VIPER Properties

    var output: TaskDetailViewOutput?

    // MARK: - UI Elements

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let titleTextField = UITextField()
    private let dateValueLabel = UILabel()
    private let descriptionTextView = UITextView()

    // MARK: - Properties

    private var isEditMode = false
    private var hasUnsavedChanges = false

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        output?.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        titleTextField.becomeFirstResponder()
    }

    // MARK: - Setup UI

    private func setupUI() {
        view.backgroundColor = .systemBackground

        navigationItem.title = isEditMode ? "Редактирование" : "Новая задача"

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        titleTextField.placeholder = "Название"
        titleTextField.font = .systemFont(ofSize: 20, weight: .semibold)
        titleTextField.borderStyle = .none
        titleTextField.clearButtonMode = .never
        titleTextField.returnKeyType = .next
        titleTextField.delegate = self
        titleTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)

        dateValueLabel.font = .systemFont(ofSize: 14)
        dateValueLabel.textColor = .secondaryLabel
        dateValueLabel.textAlignment = .left

        descriptionTextView.font = .systemFont(ofSize: 16)
        descriptionTextView.textColor = .label
        descriptionTextView.backgroundColor = .clear
        descriptionTextView.textContainerInset = .zero
        descriptionTextView.textContainer.lineFragmentPadding = 0
        descriptionTextView.delegate = self
        descriptionTextView.isScrollEnabled = false

        let descriptionPlaceholder = "Описание"
        descriptionTextView.text = descriptionPlaceholder
        descriptionTextView.textColor = .placeholderText

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [titleTextField, dateValueLabel, descriptionTextView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        setupKeyboardHandling()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            titleTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            dateValueLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 12),
            dateValueLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dateValueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            descriptionTextView.topAnchor.constraint(equalTo: dateValueLabel.bottomAnchor, constant: 20),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            descriptionTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            descriptionTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    // MARK: - Keyboard Handling

    private func setupKeyboardHandling() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Actions

    @objc private func textDidChange() {
        if !hasUnsavedChanges {
            hasUnsavedChanges = true
        }
        autoSaveIfNeeded()
    }

    private func autoSaveIfNeeded() {
        let title = titleTextField.text ?? ""
        let description = descriptionTextView.textColor == .placeholderText ? "" : descriptionTextView.text ?? ""

        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        output?.didTapSave(title: title, description: description)
    }

    // MARK: - Deinit

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITextFieldDelegate

extension TaskDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleTextField {
            descriptionTextView.becomeFirstResponder()
            return false
        }
        return true
    }
}

// MARK: - UITextViewDelegate

extension TaskDetailViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = ""
            textView.textColor = .label
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Описание"
            textView.textColor = .placeholderText
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        if !hasUnsavedChanges {
            hasUnsavedChanges = true
        }
        autoSaveIfNeeded()
    }
}

// MARK: - TaskDetailViewInput

extension TaskDetailViewController: TaskDetailViewInput {

    func setupInitialState() {
        // Начальная настройка выполняется в viewDidLoad
    }

    func displayTask(title: String?, description: String?) {
        if let title = title {
            isEditMode = true
            titleTextField.text = title
            if let description = description, !description.isEmpty {
                descriptionTextView.text = description
                descriptionTextView.textColor = .label
            }
            navigationItem.title = "Редактирование"
        } else {
            isEditMode = false
            navigationItem.title = "Новая задача"
        }
    }

    func displayDate(_ dateString: String) {
        dateValueLabel.text = dateString
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
}