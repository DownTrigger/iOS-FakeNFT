//
//  ProfileRequest.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 04.10.2026.
//

import Foundation

struct ProfileRequest: NetworkRequest {
    var endpoint: URL? {
        URL(
            string: "\(RequestConstants.baseURL)/api/v1/profile/1"
        )
    }
}
