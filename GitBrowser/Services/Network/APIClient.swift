//
//  APIClient.swift
//  GitBrowser
//
//  Created by Nibin Varghese on 2024/08/22.
//

import Foundation

enum APIError: Error {
    case invalidResponse
    case invalidData
    case decodingError
    case networkError(Error)
    case rateLimitExceeded
}

class APIClient {
    private let baseUrl = "https://api.github.com"
    private let session: URLSessionProtocol
    private let keychainService: KeychainService
    
    init(session: URLSessionProtocol = URLSession.shared, keychainService: KeychainService = KeychainService()) {
        self.session = session
        self.keychainService = keychainService
    }
    
    func performRequest<T: Codable>(endpoint: String, completion: @escaping (Result<T, APIError>) -> Void) {
        guard let url = URL(string: "\(baseUrl)\(endpoint)") else {
            completion(.failure(.invalidResponse))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        
        if let token = keychainService.retrieveToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }

            if httpResponse.statusCode == 403, let rateLimitHeader = httpResponse.allHeaderFields["X-RateLimit-Remaining"] as? String, rateLimitHeader == "0" {
                completion(.failure(.rateLimitExceeded))
                return
            }
            
            guard httpResponse.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(.decodingError))
            }
        }
        task.resume()
    }
}
