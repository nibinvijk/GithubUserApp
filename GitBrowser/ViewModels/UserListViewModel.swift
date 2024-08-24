//
//  UserListViewModel.swift
//  GitBrowser
//
//  Created by Nibin Varghese on 2024/08/22.
//

import Foundation

import Foundation

class UserListViewModel: UserListViewModelProtocol {
    private let userService: UserServiceProtocol
    private(set) var users: [User] = []
    var reloadData: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    init(userService: UserServiceProtocol) {
        self.userService = userService
    }
    
    func fetchUsers() {
        userService.fetchUsers { [weak self] result in
            switch result {
                case .success(let users):
                    self?.users.append(contentsOf: users)
                    self?.reloadData?()
                case .failure(let error):
                    self?.onError?(error)
                    print("Failed to fetch users: \(error)")
            }
        }
    }
}
