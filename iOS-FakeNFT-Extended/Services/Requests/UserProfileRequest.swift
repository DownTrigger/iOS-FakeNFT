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
        self.init(
            name: profile.name,
            description: profile.description,
            avatar: profile.avatar,
            website: profile.website,
            likes: likes
        )
    }

    init(name: String, description: String, avatar: String?, website: String?, likes: [String]) {
        var body = FormBody()
        body.add("name", name)
        body.add("description", description)
        body.add("avatar", avatar ?? "")
        body.add("website", website ?? "")
        body.add("likes", likes, whenEmpty: "null")
        rawBody = body.data
    }
}
