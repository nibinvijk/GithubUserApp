//
//  UserListViewModelTests.swift
//  GitBrowserTests
//
//  Created by Nibin Varghese on 2024/08/22.
//

import XCTest
@testable import GitBrowser

final class UserListViewModelTests: XCTestCase {
    
    var viewModel: UserListViewModel!
    var mockUserService: MockUserService!

    override func setUpWithError() throws {
        mockUserService = MockUserService()
        viewModel = UserListViewModel(userService: mockUserService)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        mockUserService = nil
    }

    func testFetchUsersSuccess() {
        let expectedUsers = [User(login: "user1", avatarUrl: "user1url", name: nil, followers: nil, following: nil),
                             User(login: "user2", avatarUrl: "user2url", name: nil, followers: nil, following: nil)]
        mockUserService.usersResult = .success(expectedUsers)
        
        viewModel.fetchUsers()

        XCTAssertEqual(viewModel.users.count, expectedUsers.count)
        XCTAssertEqual(viewModel.users[0].login, "user1")
        XCTAssertEqual(viewModel.users[1].login, "user2")
    }
    
    func testFetchUsersFailure() {
        let expectedError = NSError(domain: "error1", code: 1, userInfo: nil)
        mockUserService.usersResult = .failure(expectedError)
        
        viewModel.fetchUsers()
        
        viewModel.onError = { error in
            XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
        }
        
        XCTAssertTrue(viewModel.users.isEmpty)
    }
}
