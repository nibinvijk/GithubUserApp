//
//  APIClientTests.swift
//  GitBrowserTests
//
//  Created by Nibin Varghese on 2024/08/25.
//

import XCTest
@testable import GitBrowser

final class APIClientTests: XCTestCase {

    var apiClient: MockAPIClient!
    var session: MockURLSession!
    
    override func setUpWithError() throws {
        session = MockURLSession()
        apiClient = MockAPIClient(session: session)
    }

    override func tearDownWithError() throws {
        apiClient = nil
        session = nil
    }

    func testFetchDataSuccess() {
        let expectedJSONString = """
    [{
        "login": "mojombo",
        "avatar_url": "https://avatars.githubusercontent.com/u/1?v=4",
    }]
    """
        
        let expectedData = expectedJSONString.data(using: .utf8)!
        
        session.data = expectedData
        apiClient.result = .success([User(login: "mojombo", avatarUrl: "https://avatars.githubusercontent.com/u/1?v=4", name: nil, followers: nil, following: nil)])
        
        var result: Result<Data, Error>?
        let expectation = self.expectation(description: "completion handler called")
                
        apiClient.fetchData(from: URL(string: "https://google.com")!) { res in
            result = res
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        switch result {
            case .success(let data):
                let expectedJSON = try! JSONSerialization.jsonObject(with: expectedData, options: []) as! [[String: Any]]
                let resultJSON = try! JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]
                
                XCTAssertEqual(expectedJSON as NSArray, resultJSON as NSArray)
            default:
                XCTFail("failure")
        }
    }

    
    func testFetchDataFailure() {
        session.error = NSError(domain: "error", code: 1, userInfo: nil)
        
        var result: Result<Data, Error>?
        let expectation = self.expectation(description: "Completion handler called")
        
        apiClient.result = .failure(NSError(domain: "error", code: 1, userInfo: nil))
        
        apiClient.fetchData(from: URL(string: "https://google.com")!) { res in
            result = res
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        switch result {
            case .failure(let error as NSError):
                XCTAssertEqual(error.domain, "error")
            default:
                XCTFail("failure")
        }
    }

}
