//
//  MockAPIClient.swift
//  GitBrowser
//
//  Created by Nibin Varghese on 2024/08/25.
//

import XCTest
@testable import GitBrowser

class MockAPIClient: APIClient {
    var result: Result<[User], Error>?
    
    func fetchData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        if let result = result {
            switch result {
                case .success(let data):
                    let jsonData = try! JSONEncoder().encode(data)
                    completion(.success(jsonData))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
}
