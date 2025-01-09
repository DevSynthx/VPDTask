//
//  RepositoryService.swift
//  VPD Task
//
//  Created by Inyene on 1/9/25.
//

import Foundation

class RepositoryService {
    
    @Inject private var networkManager: NetworkProtocol
    
    func fetchRepositories(page: Int = 1, perPage: Int = 30, completion: @escaping (Result<[Repository], NetworkError>) -> Void) {
        let endpoint = GitHubEndpoint.repositories(page: page, perPage: perPage)
        networkManager.request(endpoint, completion: completion)
    }
    
    func fetchRepository(id: String, completion: @escaping (Result<Repository, NetworkError>) -> Void) {
        let endpoint = GitHubEndpoint.repository(id: id)
        networkManager.request(endpoint, completion: completion)
    }
    
    func fetchContributors(url: String, completion: @escaping (Result<[Contributors], NetworkError>) -> Void) {
        let endpoint = GitHubEndpoint.contributors(url: url)
        networkManager.request(endpoint, completion: completion)
    }
}

