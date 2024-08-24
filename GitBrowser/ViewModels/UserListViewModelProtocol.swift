//
//  UserListViewModelProtocol.swift
//  GitBrowser
//
//  Created by Nibin Varghese on 2024/08/22.
//

import Foundation

protocol UserListViewModelProtocol: AnyObject {
    var users: [User] { get }
    var reloadData: (() -> Void)? { get set }
    var onError: ((Error) -> Void)? { get set }
    func fetchUsers()
}
