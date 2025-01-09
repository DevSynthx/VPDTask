//
//  Utils.swift
//  VPD Task
//
//  Created by Inyene on 1/9/25.
//



import Foundation



protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem]? { get }
    var headers: [String: String]? { get }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}



enum GitHubEndpoint: Endpoint {
    case repositories(page: Int, perPage: Int)
    case repository(id: String)
    case contributors(url: String)
    
    
    var baseURL: String {
        return "https://api.github.com"
    }
    
    var path: String {
        switch self {
        case .repositories:
            return "/repositories"
        case .repository(let id):
            return "/repositories/\(id)"
        case .contributors(url: let url):
            return url.replacingOccurrences(of: "https://api.github.com", with: "")
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .repositories, .repository, .contributors:
            return .get
            
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .repositories(let page, let perPage):
            return [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: "\(perPage)")
            ]
        case .repository:
            return nil
            
        case .contributors:
            return nil
        }
    }
    
    var headers: [String: String]? {
        return [
            "Accept": "application/json",
            "User-Agent": "GitHubApp" 
        ]
    }
}
