//
//  URLSessionProtocol.swift
//  GitBrowser
//
//  Created by Nibin Varghese on 2024/08/25.
//

import Foundation

protocol URLSessionProtocol: AnyObject {
    func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: URLSessionProtocol {}
