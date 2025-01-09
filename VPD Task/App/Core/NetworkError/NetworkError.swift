//
//  NetworkError.swift
//  VPD Task
//
//  Created by Inyene on 1/8/25.
//

import Foundation

enum NetworkError: Error {
    case decodingError(String?)
    case invalidURL
    case invalidResponse
    case encodingError(String?)
    case urlError(URLError)
    case httpError(Int)
    case noData
    case unknown(Error?)
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .decodingError(let message):
            return message ?? "Failed to decode the response"
        case .httpError(let code):
            return handleHttpError(statusCode: code)
        case .unknown(let error):
            return error?.localizedDescription ?? "An unknown error occurred"
        case .encodingError(let message):
            return message ?? "Failed to encode the request"
        case .urlError(let urlError):
            return urlError.localizedDescription
        case .invalidURL:
            return "The URL is invalid"
        case .invalidResponse:
            return "Received an invalid response"
        case .noData:
            return "No data received from the server"
        }
    }
    
    private func handleHttpError(statusCode: Int) -> String {
        switch statusCode {
        case 400:
            return "Bad request - Please check your input"
        case 401:
            return "Unauthorized - Please login again"
        case 403:
            return "Forbidden - You don't have permission to access this resource"
        case 404:
            return "Not Found - The requested resource doesn't exist"
        case 422:
            return "Unprocessable Entity - Validation failed"
        case 429:
            return "Too Many Requests - Please try again later"
        case 500:
            return "Internal Server Error - Something went wrong on our end"
        case 502:
            return "Bad Gateway - The server received an invalid response"
        case 503:
            return "Service Unavailable - Please try again later"
        case 504:
            return "Gateway Timeout - The server took too long to respond"
        default:
            return "Please try again later"
        }
    }
}





