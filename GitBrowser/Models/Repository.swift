//
//  Repository.swift
//  GitBrowser
//
//  Created by Nibin Varghese on 2024/08/22.
//

struct Repository: Codable {
    let name: String
    let language: String?
    let stargazersCount: Int
    let description: String?
    let htmlUrl: String
    let isFork: Bool
    
    enum CodingKeys: String, CodingKey {
        case name
        case language
        case stargazersCount = "stargazers_count"
        case description
        case htmlUrl = "html_url"
        case isFork = "fork"
    }
}
