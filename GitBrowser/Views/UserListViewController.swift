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
    private var isAPICallActive: Bool = false
    private let refreshCooldown: TimeInterval = 5.0
    
    private var viewModel: UserListViewModelProtocol!
    private let loadingView = LoadingView()
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var filteredUsers: [User] = []
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "GitHub Users"
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.identifier)
        tableView.rowHeight = CELL_HEIGHT
        
        configureSubviewsAndViewModel()
        fetchUserList()
    }
    
    // MARK: - Configure subviews and viewmodel
    private func configureSubviewsAndViewModel() {
        setupRefreshControl()
        setupSearchController()
        
        setupViewModel()
    }
    
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Users"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setupViewModel() {
        let userService = UserService(apiClient: APIClient())
        viewModel = UserListViewModel(userService: userService)
        
        viewModel.reloadData = { [weak self] in
            DispatchQueue.main.async {
                self?.filteredUsers = self?.viewModel.users ?? []
                self?.updateUIonAPICompletion()
            }
        }
        
        viewModel.onError = { [weak self] error in
            DispatchQueue.main.async {
                self?.updateUIonAPICompletion(reloadTable: false)
                self?.showAlert(error: error.localizedDescription)
            }
        }
    }
    
    private func updateUIonAPICompletion(reloadTable: Bool = true) {
        self.loadingView.hide()
        self.onRefreshDataCompleted()
        
        if reloadTable {
            self.tableView.reloadData()
        }
    }
    
    private func fetchUserList() {
        if isAPICallActive { return }
       
        if !(refreshControl?.isRefreshing ?? false) {
            loadingView.show()
        }
        isAPICallActive = true
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
    
    private func clearSearchBarAndResignFirstResponder() {
        searchController.searchBar.text = nil
        searchController.searchBar.endEditing(true)
    }
    
    private func showAlert(error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true) {
            self.onRefreshDataCompleted()
        }
    }
    
    // MARK: - Action handlers
    @objc private func refreshData(_ sender: UIRefreshControl) {
        if (isAPICallActive) {
            refreshControl?.endRefreshing()
            return
        }
        
        refreshControl?.beginRefreshing()
        fetchUserList()
    }
    
    private func onRefreshDataCompleted() {
        DispatchQueue.main.async {
            self.refreshControl?.endRefreshing()
            self.updateRefreshControlTitle()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + refreshCooldown) {
            self.isAPICallActive = false
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension UserListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.identifier, for: indexPath) as? UserTableViewCell else {
            return UITableViewCell()
        }
        
        guard filteredUsers.count > indexPath.row else {
            return cell
        }
        
        let user = filteredUsers[indexPath.row]
        cell.configure(with: user)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedUser = filteredUsers[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let userRepositoryViewController = storyboard.instantiateViewController(withIdentifier: "RepositoryVC") as? UserRepositoryViewController {
            
            let userRepositoryViewModel = UserRepositoryViewModel(userService: UserService(), user: selectedUser)
            userRepositoryViewController.viewModel = userRepositoryViewModel
            
            navigationController?.pushViewController(userRepositoryViewController, animated: true)
        }
        
        clearSearchBarAndResignFirstResponder()
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

// MARK: - UISearchController Delegate
extension UserListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            filteredUsers = viewModel.users
            tableView.reloadData()
            return
        }
        
        filteredUsers = viewModel.users.filter { $0.login.lowercased().contains(searchText.lowercased()) }
        tableView.reloadData()
    }
}
