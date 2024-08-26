//
//  UserListViewController.swift
//  GitBrowser
//
//  Created by Nibin Varghese on 2024/08/22.
//

import UIKit

class UserListViewController: UITableViewController {
    
    private var shownIndexes : [IndexPath] = []
    private let CELL_HEIGHT : CGFloat = 70
    
    private var viewModel: UserListViewModelProtocol!
    private let loadingView = LoadingView()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "GitHub Users"
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.identifier)
        tableView.rowHeight = CELL_HEIGHT
        
        setupRefreshControl()
        setupViewModel()
        loadingView.show()
        viewModel.fetchUsers()
    }
    
    // MARK: - Configure subviews and viewmodel
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }
    
    @objc private func refreshData(_ sender: UIRefreshControl) {
        self.refreshControl?.beginRefreshing()
        viewModel.fetchUsers()
    }
    
    private func updateRefreshControlTitle() {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        let title = "Last refreshed: \(formatter.string(from: Date()))"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.gray
        ]
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        refreshControl?.attributedTitle = attributedTitle
    }
    
    private func onRefreshDataCompleted() {
        DispatchQueue.main.async {
            self.refreshControl?.endRefreshing()
            self.updateRefreshControlTitle()
        }
    }
    
    private func setupViewModel() {
        let userService = UserService(apiClient: APIClient())
        viewModel = UserListViewModel(userService: userService)
        
        viewModel.reloadData = { [weak self] in
            DispatchQueue.main.async {
                self?.loadingView.hide()
                self?.onRefreshDataCompleted()
                self?.tableView.reloadData()
            }
        }
        
        viewModel.onError = { [weak self] error in
            DispatchQueue.main.async {
                self?.loadingView.hide()
                self?.showAlert(error: error.localizedDescription)
            }
        }
    }
    
    private func showAlert(error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true) {
            self.onRefreshDataCompleted()
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension UserListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.identifier, for: indexPath) as? UserTableViewCell else {
            return UITableViewCell()
        }
        
        guard viewModel.users.count > indexPath.row else {
            return cell
        }
        
        let user = viewModel.users[indexPath.row]
        cell.configure(with: user)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedUser = viewModel.users[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let userRepositoryViewController = storyboard.instantiateViewController(withIdentifier: "RepositoryVC") as? UserRepositoryViewController {
            
            let userRepositoryViewModel = UserRepositoryViewModel(userService: UserService(), user: selectedUser)
            userRepositoryViewController.viewModel = userRepositoryViewModel
            
            navigationController?.pushViewController(userRepositoryViewController, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !shownIndexes.contains(indexPath) {
            shownIndexes.append(indexPath)
            
            cell.transform = CGAffineTransform(translationX: 0, y: CELL_HEIGHT)
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOffset = CGSize(width: 10, height: 10)
            cell.alpha = 0
            
            let delay = 0.05 * Double(indexPath.row)
            
            UIView.animate(withDuration: 0.5, 
                           delay: delay,
                           usingSpringWithDamping: 0.4,
                           initialSpringVelocity: 0.1,
                           options: [.curveEaseInOut],
                           animations: {
                cell.transform = CGAffineTransform.identity
                cell.alpha = 1
                cell.layer.shadowOffset = CGSize(width: 0, height: 0)
            }, completion: nil)
        }
    }
}

