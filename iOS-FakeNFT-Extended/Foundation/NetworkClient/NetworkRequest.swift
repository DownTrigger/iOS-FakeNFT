import Foundation

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

protocol NetworkRequest: Sendable {
    var endpoint: URL? { get }
    var httpMethod: HttpMethod { get }
    var rawBody: Data? { get }
}

// default values
extension NetworkRequest {
    var httpMethod: HttpMethod { .get }
    var rawBody: Data? { nil }
}
