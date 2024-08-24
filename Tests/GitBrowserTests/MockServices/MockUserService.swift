//
//  MockUserService.swift
//  GitBrowserTests
//
//  Created by Nibin Varghese on 2024/08/22.
//

import XCTest
@testable import GitBrowser

class MockUserService: UserServiceProtocol {
    var usersResult: Result<[User], Error>?
    var repositoryResult: Result<[Repository], Error>?
    var userResult: Result<User, Error>?
    
    func fetchUsers(completion: @escaping (Result<[GitBrowser.User], Error>) -> Void) {
        if let result = usersResult {
            completion(result)
        }
    }
    
    func fetchDetails(for user: String, completion: @escaping (Result<GitBrowser.User, any Error>) -> Void) {
        if let result = userResult {
            completion(result)
        }
    }
    
    func fetchRepositories(for user: String, completion: @escaping (Result<[GitBrowser.Repository], any Error>) -> Void) {
        if let result = repositoryResult {
            completion(result)
        }
    }
}
