//
//  MockURLSession.swift
//  GitBrowser
//
//  Created by Nibin Varghese on 2024/08/25.
//

import Foundation
@testable import GitBrowser

class MockURLSession: URLSessionProtocol {
    var data: Data?
    var error: Error?
    
    func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        completionHandler(data, nil, error)
        return MockURLSessionDataTask()
    }
}

class MockURLSessionDataTask: URLSessionDataTask {
    override func resume() {
        // No-op, just for mocking purposes.
    }
}
