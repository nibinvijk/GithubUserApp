//
//  UserRepositoryViewModelProtocol.swift
//  GitBrowser
//
//  Created by Nibin Varghese on 2024/08/22.
//

import Foundation

protocol UserRepositoryViewModelProtocol: AnyObject {
    var user: User { get }
    var repositories: [Repository] { get }
    var refreshUI: (() -> Void)? { get set }
    var reloadTableData: (() -> Void)? { get set }
    var onError: ((Error) -> Void)? { get set }
    func fetchUserDetails()
    func fetchRepositories()
}
