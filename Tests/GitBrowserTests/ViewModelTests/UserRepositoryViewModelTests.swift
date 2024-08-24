//
//  UserRepositoryViewModelTests.swift
//  GitBrowserTests
//
//  Created by Nibin Varghese on 2024/08/22.
//

import XCTest
@testable import GitBrowser

final class UserRepositoryViewModelTests: XCTestCase {

    var viewModel: UserRepositoryViewModel!
    var mockUserService: MockUserService!

    override func setUpWithError() throws {
        mockUserService = MockUserService()
        let user = User(login: "user1", avatarUrl: "user1url", name: nil, followers: nil, following: nil)
        viewModel = UserRepositoryViewModel(userService: mockUserService, user: user)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        mockUserService = nil
    }
    
    func testFetchUserDetailsSuccess() {
        let expectedUser = User(login: "user1", avatarUrl: "user1url", name: "user 1", followers: 1, following: 1)
        mockUserService.userResult = .success(expectedUser)
        
        viewModel.fetchUserDetails()
        
        XCTAssertEqual(viewModel.user.login, expectedUser.login)
        XCTAssertEqual(viewModel.user.name, expectedUser.name)
        XCTAssertEqual(viewModel.user.followers, expectedUser.followers)
    }

    func testFetchRepositoriesSuccess() {
        let expectedRepositories = [Repository(name: "repo1", language: "lang1", stargazersCount: 1, description: "description1", htmlUrl: "url", isFork: false), Repository(name: "repo2", language: "lang2", stargazersCount: 1, description: "description2", htmlUrl: "url", isFork: false)]
        mockUserService.repositoryResult = .success(expectedRepositories)
        
        viewModel.fetchRepositories()
        
        XCTAssertEqual(viewModel.repositories.count, expectedRepositories.count)
        XCTAssertEqual(viewModel.repositories[0].name, "repo1")
        XCTAssertEqual(viewModel.repositories[1].name, "repo2")
    }
    
    func testFetchRepositoriesSuccessAndHasForkedRepositories() {
        let expectedRepositories = [Repository(name: "repo1", language: "lang1", stargazersCount: 1, description: "description1", htmlUrl: "url", isFork: false), Repository(name: "repo2", language: "lang2", stargazersCount: 1, description: "description2", htmlUrl: "url", isFork: true)]
        mockUserService.repositoryResult = .success(expectedRepositories)
        
        viewModel.fetchRepositories()
        
        XCTAssertEqual(viewModel.repositories.count, 1)
        XCTAssertEqual(viewModel.repositories[0].name, "repo1")
    }
    
    func testFetchRepositoriesFailure() {
        let expectedError = NSError(domain: "error1", code: 1, userInfo: nil)
        mockUserService.repositoryResult = .failure(expectedError)
        
        viewModel.fetchRepositories()
        
        viewModel.onError = { error in
            XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
        }
        XCTAssertTrue(viewModel.repositories.isEmpty)
    }

}
