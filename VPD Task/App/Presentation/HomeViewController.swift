//
//  HomeViewController.swift
//  VPD Task
//
//  Created by Inyene on 1/9/25.
//

import UIKit
import Kingfisher


class HomeViewController: UIViewController {
    @Inject private var repositoryService: RepositoryService
    
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private var repositories: [Repository] = []
    private var isLoading = false
    private var currentPage = 1
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLoadingIndicator()
        fetchRepositories()
    }
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func updateLoadingState(_ loading: Bool) {
        isLoading = loading
        if loading {
            loadingIndicator.startAnimating()
            tableView.isHidden = repositories.isEmpty
        } else {
            loadingIndicator.stopAnimating()
            tableView.isHidden = false
        }
    }
    
    private func setupUI() {
        title = "Home Screen"
        view.backgroundColor = .systemBackground
        
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RepositoryCell.self, forCellReuseIdentifier: "RepositoryCell")
        view.addSubview(tableView)
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
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
     
    
    private func showError(_ error: NetworkError) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func refreshData() {
        fetchRepositories(isRefreshing: true)
    }
}

// UITableView Extension
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryCell", for: indexPath) as! RepositoryCell
        let repository = repositories[indexPath.row]
        cell.configure(with: repository)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let repository = repositories[indexPath.row]
        let detailVC = DetailsViewController(repository: repository)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height * 2 {
            fetchRepositories()
        }
    }
}


// RepositoryCell
class RepositoryCell: UITableViewCell {
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    
    private let nameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let ownerLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.numberOfLines = 2
        descriptionLabel.textColor = .secondaryLabel
        ownerLabel.font = .systemFont(ofSize: 14)
        ownerLabel.textColor = .secondaryLabel
        
        let labelsStack = UIStackView(arrangedSubviews: [nameLabel, descriptionLabel, ownerLabel])
        labelsStack.axis = .vertical
        labelsStack.spacing = 4
        labelsStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(avatarImageView)
        contentView.addSubview(labelsStack)
        
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            avatarImageView.widthAnchor.constraint(equalToConstant: 50),
            avatarImageView.heightAnchor.constraint(equalToConstant: 50),
            
            labelsStack.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            labelsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            labelsStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            labelsStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with repository: Repository) {
        nameLabel.text = repository.name.capitalized
         descriptionLabel.text = repository.description
        
         ownerLabel.text = "by \(repository.owner.login)"
         ownerLabel.textColor = .systemBlue
        
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
     
     override func prepareForReuse() {
         super.prepareForReuse()
         avatarImageView.kf.cancelDownloadTask()
         avatarImageView.image = nil
     }
}



#Preview{
    let viewController = HomeViewController()
      return UINavigationController(rootViewController: viewController)
}
