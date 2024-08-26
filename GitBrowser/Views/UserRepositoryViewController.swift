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
    private var isAPICallActive: Bool = false
    private let refreshCooldown: TimeInterval = 5.0
    
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
        fetchUserAndRepository()
    }
    
    // MARK: - Configure Subviews and View Models
    private func configureUIAndViewModel() {
        navigationItem.hidesBackButton = true
        
        let backItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(onBackBarButtonTapped))
        navigationItem.leftBarButtonItem = backItem
        
        let rightItem = UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"), style: .plain, target: self, action: #selector(onReloadTapped))
        navigationItem.rightBarButtonItem = rightItem

        setupTableView()
        bindViewModel()
    }
    
    private func fetchUserAndRepository() {
        if isAPICallActive { return }
        
        // Set the flag to prevent repeated calls with in specified time
        isAPICallActive = true
        loadingView.show()
        viewModel.fetchUserDetails()
    }
    
    private func setupTableView() {
        tableView.register(RepositoryTableViewCell.self, forCellReuseIdentifier: RepositoryTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func bindViewModel() {
        viewModel.refreshUI = { [weak self] in
            DispatchQueue.main.async {
                self?.updateUserDetails()
                self?.viewModel.fetchRepositories()
            }
        }
        
        viewModel.reloadTableData = { [weak self] in
            DispatchQueue.main.async {
                self?.onfetchAPICompletion()
                self?.tableView.reloadData()
            }
        }
        
        viewModel.onError = { [weak self]  error in
            DispatchQueue.main.async {
                self?.onfetchAPICompletion()
                self?.showError(error: error.localizedDescription)
            }
        }
    }
    
    private func onfetchAPICompletion() {
        self.loadingView.hide()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + refreshCooldown) {
            self.isAPICallActive = false
        }
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
    
    private func showError(error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Action handlers
    @objc private func onBackBarButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func onReloadTapped() {
        fetchUserAndRepository()
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
