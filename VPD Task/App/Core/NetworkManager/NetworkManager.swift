//
//  HttpClient.swift
//  VPD Task
//
//  Created by Inyene on 1/8/25.
//

import Foundation


class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://api.github.com/repositories"
    private var currentPage = 1
    private let perPage = 30
    
    private init() {}
    
    func fetchRepositories(page: Int = 1, completion: @escaping (Result<[Repository], NetworkError>) -> Void) {
        guard let url = URL(string: "\(baseURL)?page=\(page)&per_page=\(perPage)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error as? URLError {
                completion(.failure(.urlError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.httpError(httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                 let repositories = try JSONDecoder().decode([Repository].self, from: data)
                 completion(.success(repositories))
             } catch let decodingError {
                 completion(.failure(.decodingError(decodingError.localizedDescription)))
             }
        }
        task.resume()
    }
}
