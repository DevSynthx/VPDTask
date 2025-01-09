//
//  Model.swift
//  VPD Task
//
//  Created by Inyene on 1/8/25.
//

import Foundation

struct Repository: Codable {
    let id: Int
    let name: String
    let description: String?
    let owner: Owner
    let contributors: String
    let starGazed: String

    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case owner
        case contributors = "contributors_url"
        case starGazed = "stargazers_url"
    }
}

struct Owner: Codable {
    let id: Int
    let login: String
    let avatarUrl: String

    
    enum CodingKeys: String, CodingKey {
        case id
        case login
        case avatarUrl = "avatar_url"
        
    }
}


struct Contributors: Codable {
    let avatarUrl: String
    let login: String
    
    enum CodingKeys: String, CodingKey {
        case avatarUrl = "avatar_url"
        case login
    }
}
