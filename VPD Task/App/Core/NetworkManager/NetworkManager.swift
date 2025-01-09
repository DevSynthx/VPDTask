//
//  HttpClient.swift
//  VPD Task
//
//  Created by Inyene on 1/8/25.
//

import Foundation


protocol NetworkProtocol{
    func request<T: Codable>(_ endpoint: Endpoint, completion: @escaping (Result<T, NetworkError>) -> Void)
}



class NetworkManager: NetworkProtocol {
    static let shared = NetworkManager()
    private init() {}
    
    func request<T: Codable>(_ endpoint: Endpoint, completion: @escaping (Result<T, NetworkError>) -> Void) {
        guard var urlComponents = URLComponents(string: endpoint.baseURL + endpoint.path) else {
            completion(.failure(.invalidURL))
            return
        }
        
        if let queryItems = endpoint.queryItems {
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        
        if let headers = endpoint.headers {
            headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
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
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch let decodingError {
                completion(.failure(.decodingError(decodingError.localizedDescription)))
            }
        }
        task.resume()
    }
}
