import Foundation

struct UserProfileRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1")
    }
}

struct UserProfileUpdateRequest: NetworkRequest {
    var httpMethod: HttpMethod { .put }

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1")
    }

    let rawBody: Data?

    init(profile: UserProfile, likes: [String]) {
        var body = FormBody()
        body.add("name", profile.name)
        body.add("description", profile.description)
        body.add("avatar", profile.avatar ?? "")
        body.add("website", profile.website ?? "")
        body.add("likes", likes, whenEmpty: "null")
        rawBody = body.data
    }
}
