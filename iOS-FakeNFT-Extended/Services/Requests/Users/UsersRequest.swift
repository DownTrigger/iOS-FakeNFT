//
//  UsersRequest.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 02.10.2026.
//

import Foundation

struct UsersRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/users")
    }
}
