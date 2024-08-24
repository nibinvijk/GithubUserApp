//
//  UserRepositoryViewModel.swift
//  GitBrowser
//
//  Created by Nibin Varghese on 2024/08/22.
//

import Foundation

class UserRepositoryViewModel: UserRepositoryViewModelProtocol {
    
    private let userService: UserServiceProtocol
    var user: User
    private(set) var repositories: [Repository] = []
    var refreshUI: (() -> Void)?
    var reloadTableData: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    init(userService: UserServiceProtocol, user: User) {
        self.userService = userService
        self.user = user
    }
    
    func fetchUserDetails() {
        userService.fetchDetails(for: user.login) { [weak self] result in
            switch result {
                case .success(let updatedUser):
                    self?.user = updatedUser
                    self?.refreshUI?()
                case .failure(let error):
                    self?.onError?(error)
            }
        }
    }
    
    func fetchRepositories() {
        userService.fetchRepositories(for: user.login) { [weak self] result in
            switch result {
                case .success(let repositories):
                    self?.repositories = repositories.filter { !$0.isFork }
                    self?.reloadTableData?()
                case .failure(let error):
                    self?.onError?(error)
                    print("Error fetching repositories: \(error.localizedDescription)")
            }
        }
    }
}
