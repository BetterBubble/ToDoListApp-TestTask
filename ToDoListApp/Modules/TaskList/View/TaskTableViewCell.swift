import UIKit

final class TaskTableViewCell: UITableViewCell {

    // MARK: - Static Properties

    static let identifier = "TaskTableViewCell"

    // MARK: - Properties

    var onCompletionToggle: (() -> Void)?

    // MARK: - UI Elements

    private let completionIndicator: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(named: "AccentYellow")?.cgColor
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        imageView.image = UIImage(systemName: "checkmark", withConfiguration: config)
        imageView.tintColor = UIColor(named: "AccentYellow")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(named: "TextPrimary")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor(named: "TextPrimary")
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor(named: "PrimaryGray")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "TextSecondary")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private func setupUI() {
        backgroundColor = UIColor(named: "BackgroundPrimary") ?? .black
        contentView.backgroundColor = UIColor(named: "BackgroundPrimary") ?? .black
        selectionStyle = .none

        contentView.addSubview(completionIndicator)
        completionIndicator.addSubview(checkmarkImageView)
        contentView.addSubview(containerStackView)
        contentView.addSubview(separatorLine)

        // Добавляем жест нажатия на индикатор
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(completionIndicatorTapped))
        completionIndicator.addGestureRecognizer(tapGesture)
        completionIndicator.isUserInteractionEnabled = true

        containerStackView.addArrangedSubview(titleLabel)
        containerStackView.addArrangedSubview(descriptionLabel)
        containerStackView.addArrangedSubview(dateLabel)

        NSLayoutConstraint.activate([
            // Индикатор выполнения
            completionIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            completionIndicator.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            completionIndicator.widthAnchor.constraint(equalToConstant: 24),
            completionIndicator.heightAnchor.constraint(equalToConstant: 24),

            // Галочка внутри индикатора
            checkmarkImageView.centerXAnchor.constraint(equalTo: completionIndicator.centerXAnchor),
            checkmarkImageView.centerYAnchor.constraint(equalTo: completionIndicator.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 14),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 14),

            // Контейнер с текстом
            containerStackView.leadingAnchor.constraint(equalTo: completionIndicator.trailingAnchor, constant: 12),
            containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            // Разделитель - от начала индикатора до конца контента
            separatorLine.leadingAnchor.constraint(equalTo: completionIndicator.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: containerStackView.trailingAnchor),
            separatorLine.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }

    // MARK: - Actions

    @objc private func completionIndicatorTapped() {
        onCompletionToggle?()
    }

    // MARK: - Configuration

    func configure(title: String?,
                   description: String?,
                   dateString: String,
                   isCompleted: Bool,
                   isDescriptionEmpty: Bool) {

        // Заголовок
        if let title = title {
            if isCompleted {
                // Создаем зачеркнутый текст для выполненной задачи
                let attributedString = NSMutableAttributedString(string: title)
                attributedString.addAttribute(.strikethroughStyle,
                                             value: NSUnderlineStyle.single.rawValue,
                                             range: NSMakeRange(0, attributedString.length))
                attributedString.addAttribute(.foregroundColor,
                                             value: UIColor(named: "PrimaryGray") ?? UIColor.gray,
                                             range: NSMakeRange(0, attributedString.length))
                titleLabel.attributedText = attributedString
            } else {
                titleLabel.attributedText = nil
                titleLabel.text = title
                titleLabel.textColor = UIColor(named: "TextPrimary")
            }
        }

        // Описание
        descriptionLabel.text = description
        descriptionLabel.isHidden = isDescriptionEmpty

        if isCompleted {
            descriptionLabel.textColor = UIColor(named: "PrimaryGray")
        } else {
            descriptionLabel.textColor = UIColor(named: "TextPrimary")
        }

        // Дата (всегда PrimaryGray)
        dateLabel.text = dateString
        dateLabel.textColor = UIColor(named: "PrimaryGray")

        // Индикатор выполнения
        completionIndicator.backgroundColor = .clear
        completionIndicator.layer.borderColor = UIColor(named: "AccentYellow")?.cgColor
        checkmarkImageView.isHidden = !isCompleted
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.attributedText = nil
        titleLabel.text = nil
        descriptionLabel.text = nil
        dateLabel.text = nil
        checkmarkImageView.isHidden = true
        completionIndicator.backgroundColor = .clear
        descriptionLabel.isHidden = false
        onCompletionToggle = nil
    }
}
