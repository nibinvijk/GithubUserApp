//
//  UserServiceProtocol.swift
//  GitBrowser
//
//  Created by Nibin Varghese on 2024/08/22.
//

import Foundation

protocol UserServiceProtocol {
    func fetchUsers(completion: @escaping (Result<[User], Error>) -> Void)
    func fetchDetails(for user: String, completion: @escaping (Result<User, Error>) -> Void)
    func fetchRepositories(for user: String, completion: @escaping (Result<[Repository], Error>) -> Void)
}
