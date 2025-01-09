//
//  DetailsViewController.swift
//  VPD Task
//
//  Created by Inyene on 1/9/25.
//


import UIKit


class DetailsViewController: UIViewController {
    @Inject private var repositoryService: RepositoryService
    private let repository: Repository
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    init(repository: Repository) {
        self.repository = repository
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadAvatar()
        fetchContributors()
    }
    
    
    private func setupUI() {
        title = repository.name.capitalized
        view.backgroundColor = .systemBackground
        
        setupScrollView()
        setupMainStack()
    }
    
    private func setupScrollView() {
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
    
    
    private func setupMainStack() {
          let mainStack = UIStackView()
          mainStack.axis = .vertical
          mainStack.spacing = 24
          mainStack.alignment = .center
          mainStack.translatesAutoresizingMaskIntoConstraints = false
          
          // Configure avatar
          NSLayoutConstraint.activate([
              avatarImageView.widthAnchor.constraint(equalToConstant: 100),
              avatarImageView.heightAnchor.constraint(equalToConstant: 100)
          ])
          
          // Info stack
          let infoStack = createInfoStackView()
          
          // Add to main stack
          mainStack.addArrangedSubview(avatarImageView)
          mainStack.addArrangedSubview(infoStack)
          
          // Add main stack to content view
          contentView.addSubview(mainStack)
          
          NSLayoutConstraint.activate([
              mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
              mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
              mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
              mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
              
              infoStack.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor),
              infoStack.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor)
          ])
      }
      
    
    private func createAvatarContainer() -> UIView {
         let container = UIView()
         container.translatesAutoresizingMaskIntoConstraints = false
         
         container.addSubview(avatarImageView)
         
         NSLayoutConstraint.activate([
             container.heightAnchor.constraint(equalToConstant: 120),
             
             avatarImageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
             avatarImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
             avatarImageView.widthAnchor.constraint(equalToConstant: 100),
             avatarImageView.heightAnchor.constraint(equalToConstant: 100)
         ])
         
         return container
     }
     
     private func loadAvatar() {
         let placeholder = UIImage(systemName: "person.circle.fill")
         if let avatarURL = URL(string: repository.owner.avatarUrl) {
             avatarImageView.kf.setImage(
                 with: avatarURL,
                 placeholder: placeholder,
                 options: [
                     .transition(.fade(0.2)),
                     .cacheOriginalImage
                 ]
             )
         } else {
             avatarImageView.image = placeholder
         }
     }
    
    private func createInfoStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Full Name
        let fullNameLabel = createDetailLabel(title: "Full Name", detail: repository.name.capitalized)
        stackView.addArrangedSubview(fullNameLabel)
        
        // Description
        if let description = repository.description {
            let descriptionLabel = createDetailLabel(title: "Description", detail: description)
            stackView.addArrangedSubview(descriptionLabel)
        }
        
        // Owner
        let ownerLabel = createDetailLabel(title: "Owner", detail: repository.owner.login.capitalized)
        stackView.addArrangedSubview(ownerLabel)
        
        return stackView
    }
    
    private func createDetailLabel(title: String, detail: String) -> UILabel {
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
    
    
    
    private func fetchContributors(){
        repositoryService.fetchContributors(url: repository.contributors) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    print(success.count)
                case .failure(let failure):
                    print(failure.localizedDescription)
                }
            }
        }
    }
    
    /*
     private func fetchRepositories(isRefreshing: Bool = false) {
          guard !isLoading else { return }
          updateLoadingState(true)
          
          if isRefreshing {
              currentPage = 1
          }
          
          repositoryService.fetchRepositories(
              page: currentPage,
              perPage: 30
          ) { [weak self] result in
              DispatchQueue.main.async {
                  self?.updateLoadingState(false)
                  self?.refreshControl.endRefreshing()
                  
                  switch result {
                  case .success(let repositories):
                      if isRefreshing {
                          self?.repositories = repositories
                      } else {
                          self?.repositories.append(contentsOf: repositories)
                      }
                      self?.currentPage += 1
                      self?.tableView.reloadData()
                      
                  case .failure(let error):
                      self?.showError(error)
                  }
              }
          }
      }
     */
}
