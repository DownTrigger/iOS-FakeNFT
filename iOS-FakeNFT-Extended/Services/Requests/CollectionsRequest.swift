import Foundation

struct CollectionsRequest: NetworkRequest {
    let page: Int
    let size: Int
    var sortBy: String?

    var endpoint: URL? {
        var components = URLComponents(string: "\(RequestConstants.baseURL)/api/v1/collections")
        var queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "size", value: String(size))
        ]
        if let sortBy {
            queryItems.append(URLQueryItem(name: "sortBy", value: sortBy))
        }
        components?.queryItems = queryItems
        return components?.url
    }
}
