//
//  DetailsViewController.swift
//  VPD Task
//
//  Created by Inyene on 1/9/25.
//


import UIKit


// MARK: - Main View Controller
final class DetailsViewController: UIViewController {
    // MARK: - Dependencies
    @Inject private var repositoryService: RepositoryService
    private let repository: Repository
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private lazy var mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    private lazy var contributorsGridView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var contributorsLoadingIndicator: UIActivityIndicatorView = {
          let indicator = UIActivityIndicatorView(style: .medium)
          indicator.hidesWhenStopped = true
          indicator.translatesAutoresizingMaskIntoConstraints = false
          return indicator
      }()
    
    // MARK: - Initialization
    init(repository: Repository) {
        self.repository = repository
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupScrollView()
        setupMainStack()
    }
    
    private func loadData() {
        loadAvatar()
        fetchContributors()
    }
}

// MARK: - UI Setup
private extension DetailsViewController {
    func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    func setupMainStack() {
        setupAvatarImageView()
        let infoStack = createInfoStackView()
        let contributorsContainer = createContributorsHeaderContainer()
        
        [
            avatarImageView,
            infoStack,
            createSpacerView(height: 10),
            contributorsContainer,
            contributorsGridView
        ].forEach(mainStack.addArrangedSubview)
        
        contentView.addSubview(mainStack)
        
        setupMainStackConstraints(infoStack: infoStack, contributorsContainer: contributorsContainer)
    }
    
    func setupAvatarImageView() {
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 120),
            avatarImageView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    func createSpacerView(height: CGFloat) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        return view
    }
    
    func createContributorsHeaderContainer() -> UIView {
        let label = UILabel()
        label.text = "Contributors"
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor)
        ])
        
        return container
    }
    
    func setupMainStackConstraints(infoStack: UIStackView, contributorsContainer: UIView) {
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            infoStack.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor),
            infoStack.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor),
            
            contributorsContainer.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor),
            contributorsContainer.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor),
            
            contributorsGridView.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor),
            contributorsGridView.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor)
        ])
    }
}

// MARK: - Info Stack View
private extension DetailsViewController {
    func createInfoStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        [
            createDetailLabel(title: "Full Name", detail: repository.name.capitalized),
            repository.description.map { createDetailLabel(title: "Description", detail: $0) },
            createDetailLabel(title: "Owner", detail: repository.owner.login.capitalized)
        ].compactMap { $0 }.forEach(stackView.addArrangedSubview)
        
        return stackView
    }
    
    func createDetailLabel(title: String, detail: String) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        
        let text = NSMutableAttributedString(
            string: "\(title): ",
            attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium)]
        )
        text.append(NSAttributedString(
            string: detail,
            attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .regular)]
        ))
        
        label.attributedText = text
        return label
    }
}

// MARK: - Contributors Grid
private extension DetailsViewController {
    func setupContributorsGrid(with contributors: [Contributors]) {
        contributorsLoadingIndicator.stopAnimating()
        
        contributorsGridView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if contributors.isEmpty {
                 setupEmptyContributorsState()
                 return
             }
             
        
        let maxContributors = min(contributors.count, 6)
        let rowCount = 2
        let colCount = 3
        
        (0..<rowCount).forEach { row in
            let rowStack = createContributorsRow(
                row: row,
                colCount: colCount,
                maxContributors: maxContributors,
                contributors: contributors
            )
            contributorsGridView.addArrangedSubview(rowStack)
        }
    }
    
    func createContributorsRow(row: Int, colCount: Int, maxContributors: Int, contributors: [Contributors]) -> UIStackView {
        let rowStack = UIStackView()
        rowStack.axis = .horizontal
        rowStack.distribution = .fillEqually
        rowStack.spacing = 8
        
        (0..<colCount).forEach { col in
            let index = row * colCount + col
            let view = index < maxContributors
                ? createContributorImageView(avatarUrl: contributors[index].avatarUrl)
                : UIView()
            rowStack.addArrangedSubview(view)
        }
        
        return rowStack
    }
    
    func createContributorImageView(avatarUrl: String) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
        imageView.backgroundColor = .systemGray6
        
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        
        if let url = URL(string: avatarUrl) {
            imageView.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "person.circle.fill"),
                options: [.transition(.fade(0.2)), .cacheOriginalImage]
            )
        }
        
        return imageView
    }
    
    func showContributorsLoadingState() {
        contributorsGridView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        contributorsGridView.addArrangedSubview(contributorsLoadingIndicator)
        contributorsLoadingIndicator.startAnimating()
    }
    
    func setupEmptyContributorsState() {
          let emptyLabel = UILabel()
          emptyLabel.text = "No contributors found"
          emptyLabel.textColor = .secondaryLabel
          emptyLabel.font = .systemFont(ofSize: 15)
          emptyLabel.textAlignment = .center
          contributorsGridView.addArrangedSubview(emptyLabel)
      }
}

// MARK: - Data Loading
private extension DetailsViewController {
    func loadAvatar() {
        showContributorsLoadingState()
        let placeholder = UIImage(systemName: "person.circle.fill")
        
        if let avatarURL = URL(string: repository.owner.avatarUrl) {
            avatarImageView.kf.setImage(
                with: avatarURL,
                placeholder: placeholder,
                options: [.transition(.fade(0.2)), .cacheOriginalImage]
            )
        } else {
            avatarImageView.image = placeholder
        }
    }
    
    func fetchContributors() {
        repositoryService.fetchContributors(url: repository.contributors) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let contributors):
                    self?.setupContributorsGrid(with: contributors)
                case .failure(let error):
                    print(error.localizedDescription)
                    // TODO: Handle error state
                }
            }
        }
    }
}


