//
//  UserRepositoryViewController.swift
//  GitBrowser
//
//  Created by Nibin Varghese on 2024/08/22.
//

import Kingfisher
import SafariServices
import UIKit

class UserRepositoryViewController: UIViewController {
    
    var viewModel: UserRepositoryViewModelProtocol!
    private let loadingView = LoadingView()
    
    @IBOutlet private var avatarImageView: UIImageView!
    @IBOutlet private var fullNameLabel: UILabel!
    @IBOutlet private var usernameLabel: UILabel!
    @IBOutlet private var followersLabel: UILabel!
    @IBOutlet private var followingLabel: UILabel!
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUIAndViewModel()
        
        loadingView.show()
        viewModel.fetchUserDetails()
        viewModel.fetchRepositories()
    }
    
    // MARK: - Setup Methods
    private func configureUIAndViewModel() {
        let backItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backItem

        setupTableView()
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.refreshUI = { [weak self] in
            DispatchQueue.main.async {
                self?.updateUserDetails()
            }
        }
        
        viewModel.reloadTableData = { [weak self] in
            DispatchQueue.main.async {
                self?.loadingView.hide()
                self?.tableView.reloadData()
            }
        }
        
        viewModel.onError = { [weak self]  error in
            DispatchQueue.main.async {
                self?.loadingView.hide()
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func setupTableView() {
        tableView.register(RepositoryTableViewCell.self, forCellReuseIdentifier: RepositoryTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func updateUserDetails() {
        fullNameLabel.text = viewModel.user.name
        usernameLabel.text = viewModel.user.login
        followersLabel.text = "\(viewModel.user.followers ?? 0)"
        followingLabel.text = "\(viewModel.user.following ?? 0)"
        if let url = URL(string: viewModel.user.avatarUrl) {
            avatarImageView.kf.setImage(with: url)
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension UserRepositoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Repositories"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.repositories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RepositoryTableViewCell.identifier, for: indexPath) as? RepositoryTableViewCell else {
            return UITableViewCell()
        }
        
        let repository = viewModel.repositories[indexPath.row]
        cell.configure(with: repository)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let repository = viewModel.repositories[indexPath.row]
        if let url = URL(string: repository.htmlUrl) {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true, completion: nil)
        }
    }
}
