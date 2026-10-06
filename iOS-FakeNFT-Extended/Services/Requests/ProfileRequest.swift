//
//  ProfileRequest.swift
//  iOS-FakeNFT-Extended
//

import Foundation

struct ProfileRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1")
    }
}

struct ProfileUpdate: NetworkRequest {
    var httpMethod: HttpMethod { .put }

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1")
    }

    let rawBody: Data?

    init(user: UserModel) {
        var params: [String] = [
            "name=\(user.username.urlEncoded)",
            "description=\(user.bio.urlEncoded)",
            "website=\((user.userWebSite ?? "").urlEncoded)",
            "avatar=\((user.avatar ?? "").urlEncoded)"
        ]
        if user.likes.isEmpty {
            params.append("likes=null")
        } else {
            for like in user.likes {
                params.append("likes=\(like.urlEncoded)")
            }
        }
        rawBody = params.joined(separator: "&").data(using: .utf8)
    }
}

private extension String {
    var urlEncoded: String {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
}
