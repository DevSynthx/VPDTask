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
        tableView.register(RepositoryCell.self, forCellReuseIdentifier: RepositoryCell.identifier)
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
     
    
    @objc private func refreshData() {
        fetchRepositories(isRefreshing: true)
    }
}


// MARK: - UITableView Extension
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


// MARK: - Show Error Alert
private extension HomeViewController {
    func showError(_ error: NetworkError) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.fetchRepositories()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
}

#Preview{
    let viewController = HomeViewController()
      return UINavigationController(rootViewController: viewController)
}
