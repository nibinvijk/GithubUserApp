//
//  UserService.swift
//  GitBrowser
//
//  Created by Nibin Varghese on 2024/08/22.
//

import Foundation

class UserService: UserServiceProtocol {
    private let apiClient: APIClient
    
    init(apiClient: APIClient = APIClient()) {
        self.apiClient = apiClient
    }
    
    func fetchUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        apiClient.performRequest(endpoint: "/users") { (result: Result<[User], APIError>) in
            switch result {
                case .success(let users):
                    completion(.success(users))
                case .failure(let error):
                    switch error {
                        case .rateLimitExceeded:
                            print("Rate limit exceeded. Please try again later.")
                            completion(.failure(error))
                        default:
                            completion(.failure(error))
                    }
            }
        }
    }
    
    func fetchDetails(for user: String, completion: @escaping (Result<User, Error>) -> Void) {
        apiClient.performRequest(endpoint: "/users/\(user)") { (result: Result<User, APIError>) in
            switch result {
                case .success(let user):
                    completion(.success(user))
                case .failure(let error):
                    switch error {
                        case .rateLimitExceeded:
                            print("Rate limit exceeded. Please try again later.")
                            completion(.failure(error))
                        default:
                            completion(.failure(error))
                    }
            }
        }
    }
    
    func fetchRepositories(for user: String, completion: @escaping (Result<[Repository], Error>) -> Void) {
        apiClient.performRequest(endpoint: "/users/\(user)/repos") { (result: Result<[Repository], APIError>) in
            switch result {
                case .success(let repositories):
                    completion(.success(repositories))
                case .failure(let error):
                    switch error {
                        case .rateLimitExceeded:
                            print("Rate limit exceeded. Please try again later.")
                            completion(.failure(error))
                        default:
                            completion(.failure(error))
                    }
            }
        }
    }
}
